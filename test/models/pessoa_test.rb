require "test_helper"

class PessoaTest < ActiveSupport::TestCase
  test 'is validating apelido size limit' do
    pessoa = Pessoa.new apelido: 'abcdefghijklmnopqrstuvwxyz01234567890', nome: 'Valid name'
    assert_not pessoa.valid?
  end

  test 'is validating nome size limit' do
    pessoa = Pessoa.new apelido: 'valid apelido', nome: 'abcdefghijklmnopqrstuvwxyz01234567890abcdefghijklmnopqrstuvwxyz01234567890abcdefghijklmnopqrstuvwxyz01234567890abcdefghijklmnopqrstuvwxyz01234567890abcdefghijklmnopqrstuvwxyz01234567890abcdefghijklmnopqrstuvwxyz01234567890abcdefghijklmnopqrstuvwxyz01234567890abcdefghijklmnopqrstuvwxyz01234567890'
    assert_not pessoa.valid?
  end

  test 'cannot duplicate apelido' do
    fields = { apelido: 'valid apelido', nome: 'valid nome', nascimento: Date.current, stack: nil }
    assert Pessoa.create fields
    assert_raise(ActiveRecord::RecordNotUnique) { Pessoa.create fields.merge(nome: 'some other nome') }
  end

  test 'cannot duplicate nome' do
    fields = { apelido: 'valid apelido', nome: 'valid nome', nascimento: Date.current, stack: nil }
    assert Pessoa.create fields
    assert_raise(ActiveRecord::RecordNotUnique) { Pessoa.create fields.merge(apelido: 'some other apelido') }
  end

  test 'can find specific stack in stack list' do
    Pessoa.create apelido: 'foo', nome: 'foo foo', nascimento: Date.current, stack: %w[java ruby php bash]
    Pessoa.create apelido: 'bar', nome: 'bar bar', nascimento: Date.current, stack: %w[python perl bash]

    pessoa = Pessoa.search('python')
    assert_equal pessoa.count, 1
    assert_equal pessoa.first.apelido, 'bar'

    pessoa = Pessoa.search('ruby')
    assert_equal pessoa.count,1
    assert_equal pessoa.first.apelido, 'foo'

    pessoa = Pessoa.search('bash')
    assert_equal pessoa.count, 2
  end

  test 'search' do
    one = pessoas(:one)
    two = pessoas(:two)

    result = Pessoa.search('berto').first
    assert_equal result.nome, one.nome

    result = Pessoa.search('bosa').first
    assert_equal result.nome, two.nome

    result = Pessoa.search('Node').first
    assert_equal result.nome, one.nome
  end
end
