class Pessoa < ApplicationRecord
  before_validation :set_id, on: :create
  validates :apelido, presence: true, length: { maximum: 32 }
  validates :nome, presence: true, length: { maximum: 100 }

  scope :stack_one_of, ->(stack) { stack ? where('stack && ARRAY[?]::varchar[]', stack) : all }
  scope :stack_all_of, ->(stack) { stack ? where('stack @> ARRAY[?]::varchar[]', stack) : all }

  private

  def set_id
    self.id ||= SecureRandom.uuid
  end
end
