require "test_helper"

class PessoasControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    @pessoa = pessoas(:one)
    @pessoa_two = pessoas(:two)
  end

  test "should get index and return unauthorized" do
    get pessoas_url, as: :json
    assert_response :bad_request
  end

  test 'should only bring search results' do
    get pessoas_url(t: 'berto'), as: :json
    assert_response :success

    returned = JSON.parse(response.body)&.map { |pessoa| pessoa['nome'] }
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

  test "should not allow apelido not being a string" do
    post pessoas_url, params: { pessoa: { apelido: 1, nascimento: @pessoa.nascimento, nome: 'foo foo', stack: @pessoa.stack } }, as: :json

    assert_response :bad_request
  end

  test "should not allow nome not being a string" do
    post pessoas_url, params: { pessoa: { apelido: 'foo', nascimento: @pessoa.nascimento, nome: 2, stack: @pessoa.stack } }, as: :json

    assert_response :bad_request
  end

  test "should not allow stack having element not being a string" do
    post pessoas_url, params: { pessoa: { apelido: 'foo', nascimento: @pessoa.nascimento, nome: 'foo foo',
                                stack: ['ruby', 3] } }, as: :json

    assert_response :bad_request
  end

  test "should not allow duplicate pessoa" do
    # has to run this once to pre-heat the cache
    post pessoas_url, params: { pessoa: { apelido: @pessoa.apelido, nascimento: @pessoa.nascimento, nome: @pessoa.nome,
                                stack: @pessoa.stack } }, as: :json
    assert_response :created

    post pessoas_url, params: { pessoa: { apelido: @pessoa.apelido, nascimento: @pessoa.nascimento, nome: @pessoa.nome,
                                stack: @pessoa.stack } }, as: :json
    assert_response :unprocessable_entity
  end

  test "should show pessoa" do
    get pessoa_url(@pessoa), as: :json
    assert_response :success
  end

  test "should return not found pessoa" do
    get pessoa_url("unknown"), as: :json
    assert_response :not_found
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
