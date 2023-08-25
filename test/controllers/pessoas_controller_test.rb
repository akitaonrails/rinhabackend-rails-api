require "test_helper"

class PessoasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pessoa = pessoas(:one)
  end

  test "should get index" do
    get pessoas_url, as: :json
    assert_response :success
  end

  test "should create pessoa" do
    assert_difference("Pessoa.count") do
      post pessoas_url, params: { pessoa: { apelido: 'foo', nascimento: @pessoa.nascimento, nome: 'foo foo', stack: @pessoa.stack } }, as: :json
    end

    assert_response :created
  end

  test "should show pessoa" do
    get pessoa_url(@pessoa), as: :json
    assert_response :success
  end

  test "should update pessoa" do
    patch pessoa_url(@pessoa), params: { pessoa: { apelido: 'bar', nascimento: @pessoa.nascimento, nome: 'bar bar', stack: @pessoa.stack } }, as: :json
    assert_response :success
  end

  test "should destroy pessoa" do
    assert_difference("Pessoa.count", -1) do
      delete pessoa_url(@pessoa), as: :json
    end

    assert_response :no_content
  end
end
