class AnswerChoice < ApplicationRecord
  REGISTRABLE_ATTRIBUTES = %i(id question_id question_choice_id _destroy)
  belongs_to :user
  belongs_to :question
  belongs_to :question_choice

  validates :question_id, presence: true
  validates :user_id, presence: true
  validates :question_choice_id, presence: true
end
