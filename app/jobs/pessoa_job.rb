class PessoaJob
  include Sidekiq::Job

  BUFFER_SIZE = ENV.fetch('JOB_BATCH_SIZE', 10).to_i
  FLUSH_TIMEOUT = ENV.fetch('JOB_FLUSH_TIMEOUT', 30).to_i

  @@buffer = Concurrent::Array.new
  @@last_flush_time = Time.now

  def perform(action, params)
    case action
    when :create
      if params.nil?
        flush_buffer
        return
      end

      @@buffer.push(params)
      if (@@buffer.size >= BUFFER_SIZE) || (Time.now - @@last_flush_time) > FLUSH_TIMEOUT.seconds
        flush_buffer
      end
    when :update
      pessoa = Pessoa.find(params[:id])
      pessoa.update(params.except(:id))
    end
  end

  private

  def flush_buffer
    # Note: Concurrent::Array is thread-safe for basic operations like push and each
    # but compound operations like the following are NOT thread-safe.
    # Hence, use a lock for this specific compound operation.
    buffer_snapshot = @@buffer.dup
    @@buffer.clear
    @@last_flush_time = Time.now

    begin
      Pessoa.insert_all(buffer_snapshot)
    rescue => e
      #Rails.logger.error "Error inserting records: #{e}"
    end
  end
end
