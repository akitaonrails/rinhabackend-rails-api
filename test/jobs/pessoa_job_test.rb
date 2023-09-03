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
    job = PessoaJob.new
    job.buffer.clear!

    job.perform('create', { apelido: "hello", nome: "world"} )
    assert_equal 1, job.buffer.size
  end

  test 'should flush and insert all' do
    job = PessoaJob.new
    job.buffer.clear!

    validation = ->(params, _) { assert_equal PessoaJob::BUFFER_SIZE, params.size }

    Pessoa.stub(:insert_all, validation) do
      (PessoaJob::BUFFER_SIZE + 2).times do |i|
        job.perform('create', @generator.call(i))
      end
    end
    assert_equal 2, job.buffer.size
  end

  test 'flushes remaining queue items' do
    job = PessoaJob.new
    job.buffer.clear!

    assert PessoaJob::BUFFER_SIZE > 2

    Pessoa.stub(:insert_all, nil) do
      2.times do |i|
        job.perform('create', @generator.call(i))
      end
    end
    job.perform('flush', nil)

    assert_equal 0, job.buffer.size
    assert_equal 2, Rails.cache.read("#{PessoaJob::BUFFER_KEY}-counter")
  end
end
