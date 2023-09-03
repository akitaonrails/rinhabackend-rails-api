class PessoaJob
  include Sidekiq::Job

  BUFFER_SIZE = ENV.fetch('JOB_BATCH_SIZE', 10).to_i
  BUFFER_KEY = 'insert_buffer'.freeze

  def perform(action, params)
    case action
    when :create
      REDIS_QUEUE.push(BUFFER_KEY, params)
      flush_buffer if enough_buffer?
    when :update
      Pessoa.upsert(params, id: params[:id])
    when :flush
      flush_buffer
    end
  end

  private

  def enough_buffer?
    REDIS_QUEUE.size(BUFFER_KEY) >= BUFFER_SIZE
  end

  def flush_buffer
    buffer_snapshot = REDIS_QUEUE.fetch_batch(BUFFER_KEY, BUFFER_SIZE)

    Pessoa.insert_all(buffer_snapshot)
  end
end
