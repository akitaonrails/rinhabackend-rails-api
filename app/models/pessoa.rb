class Pessoa < ApplicationRecord
  HARD_SEARCH_LIMIT = 50

  include PgSearch::Model
  pg_search_scope :by_apelido_nome, against: { apelido: 'A', nome: 'B' }, using: { trigram: { threshold: 0.2 }}

  before_validation :set_id, on: :create
  validates :apelido, presence: true, length: { maximum: 32 }
  validates :nome, presence: true, length: { maximum: 100 }

  scope :stack_one_of, ->(stack) { stack ? where('stack && ARRAY[?]::varchar[]', stack) : all }
  scope :stack_all_of, ->(stack) { stack ? where('stack @> ARRAY[?]::varchar[]', stack) : all }

  def self.search(query)
    results = by_apelido_nome(query).limit(HARD_SEARCH_LIMIT).all
    results = stack_one_of(query.split(/,\s*/)).limit(HARD_SEARCH_LIMIT).all if results.empty?
    results
  end

  private

  def set_id
    self.id ||= SecureRandom.uuid
  end
end
