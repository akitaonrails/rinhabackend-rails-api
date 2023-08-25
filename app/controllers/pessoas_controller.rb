class PessoasController < ApplicationController
  JSON_FIELDS = %i[id apelido nome nascimento stack].freeze

  before_action :set_pessoa, only: %i[show update destroy]
  before_action :validate_params, only: %i[create update]

  # GET /pessoas
  def index
    if params[:t]
      render json: Pessoa.search(params[:t]), only: JSON_FIELDS
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  # GET /pessoas/1
  def show
    render json: @pessoa, only: JSON_FIELDS
  end

  def contagem
    render plain: Pessoa.count.to_s
  end

  # POST /pessoas
  def create
    @pessoa = Pessoa.new(pessoa_params)

    if @pessoa.save
      render json: @pessoa, status: :created, location: @pessoa, only: JSON_FIELDS
    else
      render json: @pessoa.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pessoas/1
  def update
    if @pessoa.update(pessoa_params)
      render json: @pessoa, only: JSON_FIELDS
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
