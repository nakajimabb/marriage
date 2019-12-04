class Question < ApplicationRecord
  REGISTRABLE_ATTRIBUTES = %w(id question_type answer_type content min_answer_size max_answer_size)

  has_many :question_choices, dependent: :destroy
  accepts_nested_attributes_for :question_choices, allow_destroy: true
  has_many :answer_values, dependent: :restrict_with_error
  has_many :answer_notes, dependent: :restrict_with_error
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id, optional: true
  belongs_to :updated_by, class_name: 'User', foreign_key: :updated_by_id, optional: true

  enum question_type: {compatibility: 1, family_relationship: 2, precious_comparison: 3, religion_value: 4}
  enum answer_type: {number: 1, precious: 3, note: 4}

  validates :content, presence: true
  validates :question_type, presence: true
  validates :answer_type, presence: true
  validates :min_answer_size, numericality: { only_integer: true, greater_than: 0, less_than: 100 }
  validates :max_answer_size, numericality: { only_integer: true, greater_than: 0, less_than: 100 }
  validates :rank, presence: true

  def check_answer_size(user_id)
    answer_size = answer_values.where(user_id: user_id).size + answer_notes.where(user_id: user_id).size
    if answer_size < min_answer_size
      errors.add(:base, I18n.t('errors.question.below_answer_size', {size: min_answer_size}))
    end
    if answer_size > max_answer_size
      errors.add(:base, I18n.t('errors.question.exceed_answer_size', {size: max_answer_size}))
    end
  end
end
