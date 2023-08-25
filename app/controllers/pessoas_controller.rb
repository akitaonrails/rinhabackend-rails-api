class PessoasController < ApplicationController
  before_action :set_pessoa, only: %i[ show update destroy ]

  # GET /pessoas
  def index
    @pessoas = if params[:t]
      Pessoa.search(params[:t])
    else
      Pessoa.all
    end
    render json: @pessoas
  end

  # GET /pessoas/1
  def show
    render json: @pessoa
  end

  # POST /pessoas
  def create
    @pessoa = Pessoa.new(pessoa_params)

    if @pessoa.save
      render json: @pessoa, status: :created, location: @pessoa
    else
      render json: @pessoa.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pessoas/1
  def update
    if @pessoa.update(pessoa_params)
      render json: @pessoa
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
      params.require(:pessoa).permit(:apelido, :nome, :nascimento, :stack)
    end
end
