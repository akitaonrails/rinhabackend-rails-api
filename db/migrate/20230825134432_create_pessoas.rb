class CreatePessoas < ActiveRecord::Migration[7.0]
  def up
    create_table :pessoas, id: :uuid do |t|
      t.string :apelido, limit: 32, null: false, index: { unique: true }
      t.string :nome, limit: 100, null: false, index: { unique: true }
      t.datetime :nascimento
      t.string :stack
      t.timestamps
    end
  end

  def down
    drop_table :pessoas
  end
end
