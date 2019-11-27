class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :update]

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
      questions = questions.map{ |question| question_to_json(question) }
      render json: {questions: questions}
    end
  end

  def create
    if current_user.role_head?
      @question = Question.new(question_params)
      @question.created_by_id = @question.updated_by_id = current_user.id
      @question.rank = Question.where(question_type: @question.question_type)
                               .maximum(:rank).to_i + 1 if @question.rank.nil?
      if @question.save
        render status: 200, json: {question: question_to_json(@question)}
      else
        render status: 500, json: {errors: @question.errors}
      end
    else
      render status: 401
    end
  end

  def update
    if current_user.role_head?
      p = question_params
      @question.assign_attributes(p)
      @question.updated_by_id = current_user.id if @question.changes.present?
      if @question.save
        render status: 200, json: {question: question_to_json(@question)}
      else
        render status: 500, json: {errors: @question.errors}
      end
    else
      render status: 401
    end
  end

private
  def set_question
    @question = Question.find(params[:id])
  end

  def question_to_json(question)
    attrs = Question::REGISTRABLE_ATTRIBUTES
    q = attrs.map { |c| [c, question.try(c)] }.to_h
    q[:question_choices_attributes] = question.question_choices
    q
  end

  def question_params
    params.require(:question)
    .permit(Question::REGISTRABLE_ATTRIBUTES +
            [question_choices_attributes: QuestionChoice::REGISTRABLE_ATTRIBUTES])
  end
end
