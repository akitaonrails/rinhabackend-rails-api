# Credit: https://github.com/lazaronixon/rinha_de_backend/blob/main/app/models/pessoa.rb
class Pessoa < ApplicationRecord
  self.ignored_columns = %w[searchable]

  before_validation :set_id, on: :create

  serialize :stack, type: Array, coder: TagCoder
  scope :search, -> (value) { where("pessoas.searchable ILIKE ?", "%#{value}%") }

  validates :apelido, presence: true, length: { maximum: 32 }
  validates :nome, presence: true, length: { maximum: 100 }
  validate :stack_must_contain_valid_elements

  private

  def set_id
    self.id ||= SecureRandom.uuid
  end

  def stack_must_contain_valid_elements
    return unless stack
    errors.add(:stack, :invalid) unless stack.all? { |item| item.is_a?(String) }
  end
end
