class PessoaJob
  include Sidekiq::Job

  BUFFER_SIZE = ENV.fetch('JOB_BATCH_SIZE', 10).to_i
  BUFFER_KEY = 'insert_buffer'.freeze

  sidekiq_options queue: BUFFER_KEY

  def buffer
    @@buffer ||= RedisQueue.new(BUFFER_KEY)
  end

  def perform(action, params)
    case action
    when 'create'
      buffer.push(params) unless params.blank?
      PessoaFlushJob.perform_async if buffer.size >= BUFFER_SIZE
    when 'flush'
      PessoaFlushJob.perform_async
    when 'update'
      Pessoa.upsert(params, id: params[:id])
    end
  end
end
