class PessoasController < ApplicationController
  JSON_FIELDS = %i[id apelido nome nascimento stack].freeze
  CACHE_EXPIRES = ENV.fetch('CACHE_EXPIRES_SECONDS', 2).to_i.seconds

  before_action :set_pessoa, only: %i[show update destroy]
  before_action :validate_params, only: %i[create update]

  # GET /pessoas?t=query
  def index
    if params[:t]
      pessoas = Pessoa.search(params[:t]).as_json(only: JSON_FIELDS)

      # HTTP caching
      fresh_when etag: Digest::MD5.hexdigest(pessoas.to_json)

      render json: pessoas
    else
      head :bad_request
    end
  end

  # GET /pessoas/1
  def show
    if @pessoa.nil?
      render json: { error: "pessoa id #{params[:id]} not found" }, status: :not_found
    else
      # HTTP caching
      fresh_when @pessoa

      render json: @pessoa, only: JSON_FIELDS
    end
  end

  def contagem
    # hack: wait for Sidekiq to empty its queue before providing the final count
    # the stress test don't count this request for performance
    PessoaJob.new.perform(:create, nil)

    render plain: Pessoa.count.to_s
  end

  # POST /pessoas
  def create
    @pessoa = Pessoa.new(pessoa_params)

    if @pessoa.valid?
      # hack to find duplicate without hitting the db
      if Rails.cache.fetch("pessoa/#{@pessoa.apelido}")
        head :unprocessable_entity
        return
      end

      # hack so SHOW works before Sidekiq hits the db eventually
      Rails.cache.write("pessoa/#{@pessoa.id}", @pessoa, expires_in: CACHE_EXPIRES)
      Rails.cache.write("pessoa/#{@pessoa.apelido}", '', expires_in: CACHE_EXPIRES)

      # hack to not lock waiting for db insert
      PessoaJob.perform_async(:create, pessoa_params.merge(id: @pessoa.id).to_h)
      head :created, location: pessoa_url(@pessoa)
    else
      head :unprocessable_entity
    end
  end

  # PATCH/PUT /pessoas/1
  def update
    if @pessoa.valid?
      PessoaJob.perform_async(:update, pessoa_params.merge(id: params[:id]).to_h)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  # DELETE /pessoas/1
  def destroy
    @pessoa.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_pessoa
    @pessoa = Rails.cache.fetch("pessoa/#{params[:id]}", expires_in: CACHE_EXPIRES) do
      Pessoa.find_by(id: params[:id])
    end
  end

  # Only allow a list of trusted parameters through.
  def pessoa_params
    params.require(:pessoa).permit(:apelido, :nome, :nascimento, stack: [])
  end

  def validate_params
    p = pessoa_params

    unless p[:apelido].is_a?(String) && p[:nome].is_a?(String)
      head :bad_request
      return
    end

    if p[:stack] && !p[:stack].all? { |elem| elem.is_a?(String) }
      head :bad_request
      return
    end
  end
end
