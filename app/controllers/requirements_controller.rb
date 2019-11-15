class RequirementsController < ApplicationController
  before_action :set_requirement, only: [:update]

  def get_by_user_id
    @requirement = Requirement.find_or_initialize_by(user_id: params[:user_id])
    render json: {requirement: @requirement}
  end

  def create
    @requirement = Requirement.new(requirement_params)
    if current_user.role_head? || current_user.role_matchmaker? || current_user.id == @requirement.user_id
      @requirement.created_by_id = @requirement.updated_by_id = current_user.id
      if @requirement.save
        render status: 200, json: {requirement: @requirement}
      else
        render status: 500, json: {errors: @requirement.errors}
      end
    else
      render status: 401
    end
  end

  def update
    if current_user.role_head? || current_user.role_matchmaker? || current_user.id == @requirement.user_id
      @requirement.assign_attributes(requirement_params)
      @requirement.updated_by_id = current_user.id if @requirement.changes.present?
      if @requirement.save
        render status: 200, json: {requirement: @requirement}
      else
        render status: 500, json: {errors: @requirement.errors}
      end
    else
      render status: 401
    end
  end

private

  def set_requirement
    @requirement = Requirement.find(params[:id])
  end

  def requirement_params
    params.fetch(:requirement, {}).permit(Requirement::REGISTRABLE_ATTRIBUTES)
  end
end
