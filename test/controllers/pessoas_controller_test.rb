require "test_helper"

class PessoasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pessoa = pessoas(:one)
    @pessoa_two = pessoas(:two)
  end

  test "should get index" do
    get pessoas_url, as: :json
    assert_response :success
  end

  test 'should only bring search results' do
    get pessoas_url(t: 'berto'), as: :json
    assert_response :success

    returned = JSON.parse(response.body).map { |pessoa| pessoa['nome'] }
    assert_includes returned, @pessoa.nome
  end

  test 'should return count of pessoas' do
    get contagem_pessoas_url, as: :plain
    assert_response :success

    assert_equal response.body, '2'
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
