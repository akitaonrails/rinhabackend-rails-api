class PessoaJob
  include SuckerPunch::Job
  workers ENV.fetch('SUCKER_PUNCH_WORKERS', 4)

  def perform(action, params)
    ActiveRecord::Base.connection_pool.with_connection do
      case action
      when :create
        pessoa = Pessoa.new(params)
        pessoa.save
      when :update
        pessoa = Pessoa.find(params[:id])
        pessoa.update(params.except(:id))
      end
    end
  end
end
