require 'test_helper'
require 'sidekiq/testing'
require 'mock_redis'
require 'minitest/autorun'

class PessoaJobTest < ActiveSupport::TestCase
  setup do
    Sidekiq::Testing.fake!
    @generator = ->(i) { { apelido: "hello #{i}", nome: 'world' } }
  end

  test 'should push new element to queue' do
    PessoaJob.new.perform(:create, { apelido: "hello", nome: "world"} )
    assert Time.now > REDIS_QUEUE.last_timestamp(PessoaJob::BUFFER_KEY)
    assert_equal 1, REDIS_QUEUE.size(PessoaJob::BUFFER_KEY)
  end

  test 'should flush and insert all' do
    validation = ->(params) { assert_equal PessoaJob::BUFFER_SIZE, params.size }

    Pessoa.stub(:insert_all, validation) do
      (PessoaJob::BUFFER_SIZE + 2).times do |i|
        PessoaJob.new.perform(:create, @generator.call(i))
      end
    end
    assert_equal 2, REDIS_QUEUE.size(PessoaJob::BUFFER_KEY)
  end

  test 'should flush after timeout' do
    PessoaJob.new.perform(:create, @generator.call(1))
    PessoaJob.new.perform(:create, @generator.call(2))
    assert_equal 2, REDIS_QUEUE.size(PessoaJob::BUFFER_KEY)

    Timecop.travel(Time.now + 1.hour) do
      Pessoa.stub(:insert_all, nil) do
        PessoaJob.new.perform(:create, @generator.call(3))
      end
    end
    assert_equal 0, REDIS_QUEUE.size(PessoaJob::BUFFER_KEY)
  end

  test 'should clean remaining buffer' do
    PessoaJob.new.perform(:create, @generator.call(1))
    PessoaJob.new.perform(:create, @generator.call(2))
    assert_equal 2, REDIS_QUEUE.size(PessoaJob::BUFFER_KEY)

    Pessoa.stub(:insert_all, nil) do
      PessoaJob.new.perform(:flush, nil)
    end
    assert_equal 0, REDIS_QUEUE.size(PessoaJob::BUFFER_KEY)
  end
end
