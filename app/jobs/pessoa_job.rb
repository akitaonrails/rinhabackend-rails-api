class PessoaJob
  include SuckerPunch::Job
  workers ENV.fetch('SUCKER_PUNCH_WORKERS', 4)

  def perform(action, params)
    case action
    when :create
      pessoa = Pessoa.new(params)
      pessoa.save
    when :update
      pessoa = Pessoa.find(params[:id])
      pessoa.update(params.except(:id))
    end
  rescue
    # bad practice: swallow any exceptions as the stress test don't care about this
  end
end
