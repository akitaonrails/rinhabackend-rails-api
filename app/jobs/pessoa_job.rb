class PessoaJob
  include Sidekiq::Job

  BUFFER_SIZE = ENV.fetch('JOB_BATCH_SIZE', 10).to_i
  BUFFER_KEY = 'insert_buffer'.freeze

  def initialize
    @@buffer ||= RedisQueue.new(BUFFER_KEY)
  end

  def perform(action, params)
    case action
    when :create
      @@buffer.push(params)
      flush_buffer if enough_buffer?
    when :update
      Pessoa.upsert(params, id: params[:id])
    when :flush
      flush_buffer
    end
  end

  private

  def enough_buffer?
    @@buffer.size >= BUFFER_SIZE
  end

  def flush_buffer
    buffer_snapshot = @@buffer.fetch_batch(BUFFER_SIZE)

    Pessoa.insert_all(buffer_snapshot)
  end

  def get_buffer
    @@buffer
  end
end
