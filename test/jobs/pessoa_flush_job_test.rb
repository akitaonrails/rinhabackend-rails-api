require 'test_helper'
require 'sidekiq/testing'
require 'mock_redis'
require 'minitest/autorun'

class PessoaFlushJob
  # to share the same MockRedis from PessoaJob
  def set_buffer(buffer)
    @@buffer = buffer
  end
end

class PessoaFlushJobTest < ActiveSupport::TestCase
  setup do
    Sidekiq::Testing.fake!
    @generator = ->(i) { { apelido: "hello #{i}", nome: 'world' } }

    @pessoa_job = PessoaJob.new
    @pessoa_job.buffer.clear!

    @flush_job = PessoaFlushJob.new
    @flush_job.set_buffer(@pessoa_job.buffer)

    2.times do |i|
      @pessoa_job.perform('create', @generator.call(i))
    end

    @insert_mock = Minitest::Mock.new
    @insert_mock.expect(:insert_all, nil)
  end

  test 'flush batch' do
    PessoaJob::BUFFER_SIZE.times do |i|
      @pessoa_job.perform('create', @generator.call(i))
    end
    assert_equal 12, @pessoa_job.buffer.size

    Pessoa.stub(:insert_all, @insert_mock) do
      @flush_job.perform
    end
    assert_equal 2, @pessoa_job.buffer.size
  end

  test 'flushes remaining items' do
    assert PessoaJob::BUFFER_SIZE > 2
    assert_equal 2, @pessoa_job.buffer.size

    Pessoa.stub(:insert_all, @insert_mock) do
      @flush_job.perform
    end
    assert_equal 0, @pessoa_job.buffer.size
  end
end
