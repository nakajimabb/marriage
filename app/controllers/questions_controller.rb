class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :update]

  def index
    if params[:question_type]
      questions = Question.where(question_type: params[:question_type]).order(:rank)
      questions = questions.map{ |question| question_to_json(question, true, params[:answer], params[:user_id]) }
      render json: {questions: questions}
    else
      render json: {questions: Question.none}
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
    errors = Hash.new('')
    target_user = User.find_by_id(answers_params[:user][:id]) if answers_params[:user]
    answer_choices = target_answer_choices
    answer_notes = target_answer_notes
    begin
      if authorized?(current_user, target_user)
        AnswerChoice.transaction do
          # 回答(質問) 削除・保存
          destroy_answer_choices.each(&:delete)
          answer_choices.each.each(&:save!)
          # 回答(記述) 削除・保存
          destroy_answer_notes.each(&:delete)
          answer_notes.each.each(&:save!)
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
      answer_choices.each { |choice| errors[choice.question_id] += choice.errors.full_messages.join(', ') if choice.errors.present?  }
      answer_notes.each  { |note|  errors[note.question_id]  += note.errors.full_messages.join(', ')  if note.errors.present?  }
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
    user_id = user_id.split(',') if user_id   # 複数指定可能
    q = attrs.map { |c| [c, question.try(c)] }.to_h
    if choice
      q[:question_choices_attributes] = question.question_choices
    end
    if answer && user_id
      q[:answer_choices_attributes] = question.answer_choices.where(user_id: user_id)
      q[:answer_notes_attributes] = question.answer_notes.where(user_id: user_id)
    end
    q
  end

  def destroy_answer_choices
    (answers_params[:answer_choices_attributes] || []).select { |p| p[:_destroy] }
    .map do |p|
      answer_choice = AnswerChoice.find_or_initialize_by(id: p[:id])
      answer_choice.attributes = p.select{ |k, _| k.to_sym != :_destroy }
      answer_choice
    end
  end

  def target_answer_choices
    user_id = answers_params[:user][:id] if answers_params[:user]
    (answers_params[:answer_choices_attributes] || []).select { |p| !p[:_destroy] }
    .map do |p|
      answer_choice = AnswerChoice.find_or_initialize_by(id: p[:id])
      answer_choice.attributes = p.select{ |k, _| k.to_sym != :_destroy }
      answer_choice.user_id = user_id
      answer_choice
    end
  end

  def destroy_answer_notes
    (answers_params[:answer_notes_attributes] || []).select { |p| p[:_destroy] }
        .map do |p|
      answer_note = AnswerNote.find_or_initialize_by(id: p[:id])
      answer_note.attributes = p.select{ |k, _| k.to_sym != :_destroy }
      answer_note
    end
  end

  def target_answer_notes
    user_id = answers_params[:user][:id] if answers_params[:user]
    (answers_params[:answer_notes_attributes] || []).select { |p| !p[:_destroy] }
        .map do |p|
      answer_note = AnswerNote.find_or_initialize_by(id: p[:id])
      answer_note.attributes = p.select{ |k, _| k.to_sym != :_destroy }
      answer_note.user_id = user_id
      answer_note
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
                answer_choices_attributes: AnswerChoice::REGISTRABLE_ATTRIBUTES,
                answer_notes_attributes: AnswerNote::REGISTRABLE_ATTRIBUTES)
  end
end
