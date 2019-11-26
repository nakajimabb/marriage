class Question < ApplicationRecord
  REGISTRABLE_ATTRIBUTES = %w(id question_type answer_type content min_answer_size
                              max_answer_size created_by_id updated_by_id index)

  attr_accessor :index
  has_many :question_choices, dependent: :destroy
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id, optional: true
  belongs_to :updated_by, class_name: 'User', foreign_key: :updated_by_id, optional: true

  enum question_type: {compatibility: 1, family_relationship: 2, precious_comparison: 3, religiou_value: 4}
  enum answer_type: {number: 1, precious: 3, note: 4}

  validates :content, presence: true
  validates :question_type, presence: true
  validates :answer_type, presence: true
  validates :min_answer_size, numericality: { only_integer: true, greater_than: 0, less_than: 100 }
  validates :max_answer_size, numericality: { only_integer: true, greater_than: 0, less_than: 100 }
end
