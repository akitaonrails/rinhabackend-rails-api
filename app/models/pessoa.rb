class Pessoa < ApplicationRecord
  self.ignored_columns = %w[searchable]

  serialize :stack, type: Array, coder: TagCoder

  scope :search, -> (value) { where("pessoas.searchable ILIKE ?", "%#{value}%") }

  validates :apelido,    presence: true, length: { maximum: 32  }
  validates :nome,       presence: true, length: { maximum: 100 }
  validates :nascimento, presence: true

  validate :stack_must_contain_valid_elements

  private
    def stack_must_contain_valid_elements
      errors.add(:stack, :invalid) unless stack.all? { |item| valid_stack_element?(item) }
    end

    def valid_stack_element?(item)
      item.is_a?(String) && item.present? && item.size <= 32
    end
end
