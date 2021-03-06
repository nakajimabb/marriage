class QuestionChoice < ApplicationRecord
  REGISTRABLE_ATTRIBUTES = %i(id label value)
  belongs_to :question

  validates :label, presence: true
  validates :value, presence: true

  def empty?
    label.blank? && value.blank?
  end
end
