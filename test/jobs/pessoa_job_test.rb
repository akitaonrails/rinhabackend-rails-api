require 'test_helper'

class PessoaJobTest < ActiveSupport::TestCase
  setup do
    # Make sure the buffer is empty before each test
    PessoaJob.class_variable_set(:@@buffer, Concurrent::Array.new)
    PessoaJob.class_variable_set(:@@last_flush_time, Time.now)
  end

  test "buffers until size reaches BUFFER_SIZE and then flushes" do
    # Seed data until buffer reaches BUFFER_SIZE - 1
    assert_no_difference('Pessoa.count') do
      (PessoaJob::BUFFER_SIZE - 1).times do |i|
        PessoaJob.new.perform(:create, apelido: "John_#{i}", nome: "Doe_#{i}", nascimento: '2000-01-01', stack: ['Ruby'])
      end
    end # No flush should have occurred

    # One more to reach BUFFER_SIZE
    assert_difference('Pessoa.count', PessoaJob::BUFFER_SIZE) do
      PessoaJob.new.perform(:create, apelido: "John_#{PessoaJob::BUFFER_SIZE}", nome: "Doe_#{PessoaJob::BUFFER_SIZE}", nascimento: '2000-01-01', stack: ['Ruby'])
    end # Now it should flush
  end

  test "flushes after FLUSH_TIMEOUT" do
    assert_difference("Pessoa.count", 2) do
      # Seed just one data point
      PessoaJob.new.perform(:create, apelido: 'John_0', nome: 'Doe_0', nascimento: '2000-01-01', stack: ['Ruby'])

      # Move time forward beyond FLUSH_TIMEOUT
      Timecop.freeze(Time.now + (PessoaJob::FLUSH_TIMEOUT + 1).seconds) do
        PessoaJob.new.perform(:create, apelido: 'Jane_1', nome: 'Doe_1', nascimento: '2000-01-02', stack: ['JS'])
      end
    end
  end
end
