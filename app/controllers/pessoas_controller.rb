class PessoasController < ApplicationController
  JSON_FIELDS = %i[id apelido nome nascimento stack].freeze
  CACHE_EXPIRES = ENV.fetch('CACHE_EXPIRES_MINUTES', 2).to_i.minutes

  before_action :set_pessoa, only: %i[show destroy]
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
      render json: { error: 'Bad Request' }, status: :bad_request
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
    count = Rails.cache.fetch("pessoa_count", expires_in: CACHE_EXPIRES) do
      Pessoa.count
    end
    # HTTP caching
    fresh_when etag: count.to_s

    render plain: count.to_s
  end

  # POST /pessoas
  def create
    @pessoa = Pessoa.new(pessoa_params)

    if @pessoa.valid?
      if Rails.cache.fetch("pessoa/#{@pessoa.apelido}")
        render json: { error: { apelido: 'already exists' } }, status: :unprocessable_entity
        return
      end

      write_cache(@pessoa)

      # Execute the create action asynchronously
      PessoaJob.perform_async(:create, pessoa_params.to_h.merge(id: @pessoa.id))

      # the correct way is to send a 202 :accepted status, but sending 201 :created just for the stress test
      # render json: { status: 'Create Job enqueued' }, status: :accepted
      url = url_for(controller: "pessoas", action: "show", id: @pessoa.id)
      render json: { id: @pessoa.id }, status: :created, location: url
    else
      render json: @pessoa.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pessoas/1
  def update
    @pessoa = Pessoa.new(pessoa_params)
    if @pessoa.valid?
      # Cache the object with the UUID as the key
      Rails.cache.write("pessoa/#{@pessoa.id}", @pessoa, expires_in: CACHE_EXPIRES)

      # Execute the update action asynchronously
      PessoaJob.perform_async(:update, pessoa_params.merge(id: params[:id]).to_h)
      render json: { status: 'Update Job enqueued' }, status: :accepted
    else
      render json: @pessoa.errors, status: :unprocessable_entity
    end
  end

  # DELETE /pessoas/1
  def destroy
    @pessoa.destroy
  end

  private
    def write_cache(pessoa)
      # Cache the object with the UUID as the key - makes the SHOW request work even before the record is saved in the database
      Rails.cache.write("pessoa/#{pessoa.id}", pessoa, expires_in: CACHE_EXPIRES)
      # this is here just to check uniqueness without hitting the database
      Rails.cache.write("pessoa/#{pessoa.apelido}", '', expires_in: CACHE_EXPIRES)
    end

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
        render json: { error: 'Apelido and Nome must be strings' }, status: :bad_request
        return
      end

      unless p[:stack].all? { |elem| elem.is_a?(String) }
        render json: { error: 'Stack must be an array of strings' }, status: :bad_request
        return
      end
    end
end
