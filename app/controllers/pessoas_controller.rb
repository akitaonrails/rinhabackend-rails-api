class PessoasController < ApplicationController
  JSON_FIELDS = %i[id apelido nome nascimento stack].freeze
  CACHE_EXPIRES = ENV.fetch('CACHE_EXPIRES_MINUTES', 2).to_i.minutes

  before_action :set_pessoa, only: %i[show update destroy]
  before_action :validate_params, only: %i[create update]

  # GET /pessoas
  def index
    if params[:t]
      # Caching query in Rails cache
      pessoas = Rails.cache.fetch("pessoa_search_#{params[:t]}", expires_in: CACHE_EXPIRES) do
        Pessoa.search(params[:t]).as_json(only: JSON_FIELDS)
      end

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
      render json: { error: "pessoa id #{params[:id]} not found"}, status: :not_found
    else
      # HTTP caching
      fresh_when @pessoa

      render json: @pessoa, only: JSON_FIELDS
    end
  end

  def contagem
    render plain: Pessoa.count.to_s
  end

  # POST /pessoas
  def create
    @pessoa = Pessoa.new(pessoa_params)

    if @pessoa.valid?
      begin
        if @pessoa.save
          head :created, location: pessoa_url(@pessoa)
        else
          head :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotUnique => e
        head :unprocessable_entity
      end
    else
      head :unprocessable_entity
    end
  end

  # PATCH/PUT /pessoas/1
  def update
    if @pessoa.update(pessoa_params)
      render json: @pessoa, only: JSON_FIELDS
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

      unless p[:stack].all? { |elem| elem.is_a?(String) }
        head :bad_request
        return
      end
    end
end
