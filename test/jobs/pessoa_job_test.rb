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

  test 'should send to flush queue' do
    job = PessoaJob.new
    job.buffer.clear!

    mock = Minitest::Mock.new
    mock.expect(:perform_async, nil)

    PessoaFlushJob.stub(:perform_async, mock) do
      (PessoaJob::BUFFER_SIZE + 2).times do |i|
        job.perform('create', @generator.call(i))
      end
    end
  end

  test 'flushes remaining queue items' do
    job = PessoaJob.new
    job.buffer.clear!

    assert PessoaJob::BUFFER_SIZE > 2

    mock = Minitest::Mock.new
    mock.expect(:perform_async, nil)

    PessoaFlushJob.stub(:perform_async, mock)  do
      2.times do |i|
        job.perform('create', @generator.call(i))
      end
    end
    job.perform('flush', nil)
  end
end
