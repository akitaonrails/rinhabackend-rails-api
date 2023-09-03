class PessoaJob
  include Sidekiq::Job

  BUFFER_SIZE = ENV.fetch('JOB_BATCH_SIZE', 10).to_i
  BUFFER_KEY = 'insert_buffer'.freeze

  def buffer
    @@buffer ||= RedisQueue.new(BUFFER_KEY)
  end

  def perform(action, params)
    case action
    when 'create'
      buffer.push(params) unless params.blank?
      flush if enough_buffer?
    when 'flush'
      flush
    when 'update'
      Pessoa.upsert(params, id: params[:id])
    end
  end

  private

  def enough_buffer?
    buffer.size >= BUFFER_SIZE
  end

  def flush
    buffer_snapshot = buffer.fetch_batch(BUFFER_SIZE)
    buffer_snapshot.each do |b|
      b['stack'] = nil unless b.key?('stack')
      b['nascimento'] = nil unless b.key?('nascimento')
    end

    begin
      Pessoa.insert_all(buffer_snapshot, returning: false)
    rescue => e
      Sidekiq.logger.error "ERROR: #{e} #{buffer_snapshot}"
      raise e
    ensure
      buffer.counter
    end
  end
end
