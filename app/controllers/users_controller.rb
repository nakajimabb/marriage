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
      user = @user.attributes
      user.merge!(avatar_url: @user.avatar_url)
      render json: {user: user}
    else
      render status: 401
    end
  end

  def create
    if current_user&.admin?
      @user = User.new(user_params)
      if @user.save
        render status: 200, json: {users: @user}
      else
        render status: 500, json: {errors: @user.errors}
      end
    else
      render status: 401
    end
  end

  def update
    if current_user&.admin? || current_user&.id == @user.id
      p = user_params
      if p[:password].blank? && p[:password_confirmation].blank?
        p.delete(:password)
        p.delete(:password_confirmation)
      end
      if @user.update(p)
        render status: 200, json: {users: @user}
      else
        render status: 500, json: {errors: @user.errors}
      end
    else
      render status: 401
    end
  end

  def destroy
    if current_user&.admin?
      @user.destroy
      render status: 200
    else
      render status: 401
    end
  end

private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.fetch(:user, {}).permit(User::REGISTRABLE_ATTRIBUTES)
  end
end
