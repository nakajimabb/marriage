class QuestionsController < ApplicationController
  class QuestionException < StandardError
    attr_accessor :question

    def initialize(question)
      self.question = question
      super
    end
  end

  def index
    if params[:question_type]
      questions = Question.where(question_type: params[:question_type]).order(:rank)
      render json: {questions: questions}
    end
  end

  def save_collection
    questions = target_questions
    begin
      Question.transaction do
        rank = Question.where(question_type: :compatibility).maximum(:rank) + 1
        questions.each do |question|
          if question.new_record?
            question.created_by_id = question.updated_by_id = current_user.id
            question.rank = rank
            rank += 1
          else
            question.updated_by_id = current_user.id
          end
          raise QuestionException.new(question) unless question.save
        end
      end
      render status: 200
    rescue => e
      render status: 500, json: {errors: e.question.errors, index: e.question.index}
    end
  end

private
  def target_questions
    questions = []
    if question_collection_params.has_key?(:question_attributes)
      question_collection_params[:question_attributes].each do |i, p|
        question = Question.find_or_initialize_by(id: p[:id])
        question.attributes = p
        question.index = i
        questions << question
      end
    end
    questions
  end

  def question_collection_params
    params.fetch(:form_question_collection, {})
    .permit(question_attributes: Question::REGISTRABLE_ATTRIBUTES)
  end
end
