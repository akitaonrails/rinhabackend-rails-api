class AddIndexPessoasOnSearch < ActiveRecord::Migration[7.0]
  def change
    add_column :pessoas, :searchable, :virtual, type: :text, as: "nome || ' ' || apelido || ' ' || coalesce(stack, ' ')", stored: true
    add_index  :pessoas, :searchable, using: :gist, opclass: :gist_trgm_ops
  end
end
