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
      questions = questions.map{ |question| question_to_json(question, true, params[:answer], params[:user_id]) }
      render json: {questions: questions}
    end
  end

  def create
    if current_user.role_head?
      @question = Question.new(question_params)
      @question.created_by_id = @question.updated_by_id = current_user.id
      @question.rank = Question.where(question_type: @question.question_type)
                               .maximum(:rank).to_i + 1 if @question.rank.nil?
      @question.question_choices.each { |qc| qc.delete if qc.empty? }
      if @question.save
        render status: 200, json: {question: question_to_json(@question.reload)}
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
      @question.question_choices.each { |qc| qc.delete if qc.empty? }
      if @question.save
        render status: 200, json: {question: question_to_json(@question.reload)}
      else
        render status: 500, json: {errors: @question.errors}
      end
    else
      render status: 401
    end
  end

  def save_answers
    errors = {}
    target_user = User.find_by_id(answers_params[:user][:id]) if answers_params[:user]
    begin
      if authorized?(current_user, target_user)
        AnswerValue.transaction do
          destroy_answer_values.each(&:delete)
          target_answer_values.each.each(&:save!)

          # 回答数チェック
          target_questions.each do |question|
            question.check_answer_size(target_user.id)
            if question.errors.present?
              errors[question.id] = question.errors.full_messages.join(', ')
            end
          end
          raise if errors.present?
        end
        render status: 200
      else
        render status: 401
      end
    rescue => e
      render status: 500, json: {errors: errors}
    end
  end

private
  def set_question
    @question = Question.find(params[:id])
  end

  def authorized?(user, target_user)
    user.role_head? || (user.role_matchmaker? && target_user.matchmaker_id == user.id)
  end

  def question_to_json(question, choice=true, answer=false, user_id=nil)
    attrs = Question::REGISTRABLE_ATTRIBUTES
    q = attrs.map { |c| [c, question.try(c)] }.to_h
    if choice
      q[:question_choices_attributes] = question.question_choices
    end
    if answer && user_id
      q[:answer_values_attributes] = question.answer_values.where(user_id: user_id)
    end
    q
  end

  def destroy_answer_values
    (answers_params[:answer_values_attributes] || []).select { |p| p[:_destroy] }
    .map do |p|
      answer_value = AnswerValue.find_or_initialize_by(id: p[:id])
      answer_value.attributes = p.select{ |k, _| k.to_sym != :_destroy }
      answer_value
    end
  end

  def target_answer_values
    user_id = answers_params[:user][:id] if answers_params[:user]
    (answers_params[:answer_values_attributes] || []).select { |p| !p[:_destroy] }
    .map do |p|
      answer_value = AnswerValue.find_or_initialize_by(id: p[:id])
      answer_value.attributes = p.select{ |k, _| k.to_sym != :_destroy }
      answer_value.user_id = user_id
      answer_value
    end
  end

  def target_questions
    questions = (answers_params[:questions] || [])
    Question.where(id: questions.map{ |question| question[:id] })
  end

  def question_params
    params.require(:question)
    .permit(Question::REGISTRABLE_ATTRIBUTES +
            [question_choices_attributes: QuestionChoice::REGISTRABLE_ATTRIBUTES])
  end

  def answers_params
    params.fetch(:form_answers, {})
        .permit(user: [:id],
                questions: [:id],
                answer_values_attributes: AnswerValue::REGISTRABLE_ATTRIBUTES)
  end
end
