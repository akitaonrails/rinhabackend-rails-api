class PessoaFlushJob
  include Sidekiq::Job

  sidekiq_options queue: 'flush'

  def buffer
    @@buffer ||= RedisQueue.new(PessoaJob::BUFFER_KEY)
  end

  def perform
    buffer_snapshot = buffer.fetch_batch(PessoaJob::BUFFER_SIZE)
    buffer_snapshot.each do |b|
      b['stack'] = nil unless b.key?('stack')
      b['nascimento'] = nil unless b.key?('nascimento')
    end

    begin
      Pessoa.insert_all(buffer_snapshot, returning: false)
    rescue => e
      Sidekiq.logger.error "ERROR: #{e} #{buffer_snapshot}"
    ensure
      buffer.counter
    end
  end
end
