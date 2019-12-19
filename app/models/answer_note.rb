class AnswerNote < ApplicationRecord
  REGISTRABLE_ATTRIBUTES = %i(id question_id note _destroy)
  belongs_to :question
  belongs_to :user

  validates :question_id, presence: true
  validates :user_id, presence: true
  validates :note, presence: true
end
