class AnswerValue < ApplicationRecord
  REGISTRABLE_ATTRIBUTES = %w(id question_id value _destroy)
  belongs_to :question
  belongs_to :user

  validates :question_id, presence: true
  validates :user_id, presence: true
end
