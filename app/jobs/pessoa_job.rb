class PessoaJob
  include Sidekiq::Job

  BUFFER_SIZE = ENV.fetch('JOB_BATCH_SIZE', 10).to_i
  FLUSH_TIMEOUT = ENV.fetch('JOB_FLUSH_TIMEOUT', 30).to_i
  BUFFER_KEY = 'insert_buffer'.freeze

  def perform(action, params)
    case action
    when :create
      if params.nil?
        flush_buffer
        return
      end

      last = REDIS_QUEUE.last_timestamp(BUFFER_KEY) || Time.now
      REDIS_QUEUE.push(BUFFER_KEY, params)
      flush_buffer if enough_buffer? || timedout?(last)
    when :update
      pessoa = Pessoa.find(params[:id])
      pessoa.update(params.except(:id))
    end
  end

  private

  def enough_buffer?
    REDIS_QUEUE.size(BUFFER_KEY) >= BUFFER_SIZE
  end

  def timedout?(timestamp)
    (Time.now - timestamp) > FLUSH_TIMEOUT.seconds
  end

  def flush_buffer
    buffer_snapshot = REDIS_QUEUE.fetch_batch(BUFFER_KEY, BUFFER_SIZE)

    begin
      Pessoa.insert_all(buffer_snapshot)
    rescue => e
      Rails.logger.error "Error inserting records: #{e}"
    end
  end
end
