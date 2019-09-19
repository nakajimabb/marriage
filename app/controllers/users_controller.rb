class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    if current_user&.admin?
      render json: {users: User.all}
    else
      render status: 401
    end
  end

  def show
    if current_user&.admin? || current_user&.id == @user.id
      render json: {user: @user}
    else
      render status: 401
    end
  end

  def create
    if current_user&.admin?
      @user = User.new(user_params)
      if @user.save
        render json: {user: @user}
      else
        render status: 500, json: {user: @user}
      end
    else
      render status: 401
    end
  end

  def update
    if current_user&.admin? || current_user&.id == @user.id
      if @user.update(user_params)
        render json: {user: @user}
      else
        render status: 500, json: {user: @user}
      end
    else
      render status: 401
    end
  end

private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(User::REGISTRABLE_ATTRIBUTES)
  end
end
