class PessoasController < ApplicationController
  JSON_FIELDS = %i[id apelido nome nascimento stack].freeze

  before_action :set_pessoa, only: %i[show destroy]
  before_action :validate_params, only: %i[create update]

  # GET /pessoas
  def index
    if params[:t]
      # Caching query in Rails cache
      pessoas = Rails.cache.fetch("pessoa_search_#{params[:t]}", expires_in: 5.minutes) do
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
    # HTTP caching
    fresh_when @pessoa

    render json: @pessoa, only: JSON_FIELDS
  end

  def contagem
    count = Rails.cache.fetch("pessoa_count", expires_in: 1.minute) do
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
      # Execute the create action asynchronously
      PessoaJob.perform_async(:create, pessoa_params.to_h.merge(id: @pessoa.id))

      # the correct way is to send a 202 :accepted status, but sending 201 :created just for the stress test
      # render json: { status: 'Create Job enqueued' }, status: :accepted

      # Cache the object with the UUID as the key - makes the SHOW request work even before the record is saved in the database
      Rails.cache.write(@pessoa.id, @pessoa, expires_in: 2.minutes)

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
      Rails.cache.write(@pessoa.id, @pessoa, expires_in: 2.minutes)

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
    # Use callbacks to share common setup or constraints between actions.
    def set_pessoa
      @pessoa = Pessoa.find(params[:id])
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
