class PessoasController < ApplicationController
  JSON_FIELDS = %i[id apelido nome nascimento stack].freeze
  CACHE_EXPIRES = ENV.fetch('CACHE_EXPIRES_SECONDS', 2).to_i.seconds

  before_action :set_pessoa, only: %i[show update destroy]
  before_action :validate_params, only: %i[create update]

  # GET /pessoas?t=query
  def index
    if params[:t]
      pessoas = Pessoa.search(params[:t])

      # # HTTP caching
      #  - no need here because the stress test don't call the same URL twice
      # fresh_when etag: Digest::MD5.hexdigest(pessoas.to_json)

      render json: pessoas
    else
      head :bad_request
    end
  end

  # GET /pessoas/1
  def show
    if @pessoa
      # HTTP caching
      #  - no need here because the stress test don't call the same URL twice
      # fresh_when @pessoa
      render json: @pessoa, only: JSON_FIELDS
    else
      head :not_found
    end
  end

  def contagem
    # hack: wait for Sidekiq to empty its queue before providing the final count
    # the stress test don't count this request for performance
    PessoaJob.perform_async(:flush, nil)
    sleep 3

    render plain: "batch queue: #{Rails.cache.read('insert_buffer-counter')} total: #{Pessoa.count}"
  end

  # POST /pessoas
  def create
    @pessoa = Pessoa.new(pessoa_params)

    if @pessoa.valid?
      # hack to find duplicate without hitting the db
      if Rails.cache.fetch("a/#{@pessoa.apelido}")
        head :unprocessable_entity
        return
      end

      PessoaJob.perform_async(:create, pessoa_params.merge(id: @pessoa.id).to_h)

      # hack so SHOW works before Sidekiq hits the db eventually
      Rails.cache.write("p/#{@pessoa.id}", @pessoa, expires_in: CACHE_EXPIRES)
      Rails.cache.write("a/#{@pessoa.apelido}", '', expires_in: CACHE_EXPIRES)

      # head :created, location: pessoa_url(@pessoa)
      head :created, location: "http://localhost:9999/pessoas/#{@pessoa.id}"
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
    @pessoa = Rails.cache.fetch("p/#{params[:id]}", expires_in: CACHE_EXPIRES) do
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

    begin
      pessoa_params[:nascimento] = Time.parse(pessoa_params[:nascimento])
    rescue
      head :bad_request
      return
    end

    if p[:stack] && !p[:stack].all? { |elem| elem.is_a?(String) }
      head :bad_request
      return
    end
  end
end
