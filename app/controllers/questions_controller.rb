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
    begin
      if params[:question_type]
        question_type = params[:question_type].to_sym
        rank = Question.where(question_type: question_type).maximum(:rank).to_i + 1
        questions = target_questions(question_type)
        Question.transaction do
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
        questions = Question.where(question_type: question_type).order(:rank)
        render status: 200, json: {questions: questions}
      else
        render status: 501
      end
    rescue => e
      render status: 500, json: {errors: e.question.errors, index: e.question.index}
    end
  end

private
  def empty_params?(p)
    Question::REGISTRABLE_ATTRIBUTES.all?{ |c| p[c].blank? }
  end

  def target_questions(question_type)
    questions = []
    if question_collection_params.has_key?(:question_attributes)
      question_collection_params[:question_attributes].each do |i, p|
        if !empty_params?(p)
          question = Question.find_or_initialize_by(id: p[:id])
          question.attributes = p
          question.question_type = question_type
          question.index = i
          questions << question
        end
      end
    end
    questions
  end

  def question_collection_params
    params.fetch(:form_question_collection, {})
    .permit(question_attributes: Question::REGISTRABLE_ATTRIBUTES)
  end
end
