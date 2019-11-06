class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def courtships
    if current_user&.role_matchmaker?
      users = current_user.courtships.map{ |user| User::LIST_ATTRIBUTES.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    end
  end

  def index
    if current_user&.role_head?
      users = User.all.map{ |user| User::LIST_ATTRIBUTES.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    else
      render status: 401
    end
  end

  def show
    if current_user&.role_head? || current_user&.id == @user.matchmaker_id
      attributes = User::LIST_ATTRIBUTES
    else
      attributes = User::PUBLIC_ATTRIBUTES
    end
    user = attributes.map { |c| [c, @user.try(c)] }.to_h
    render json: {user: user}
  end

  def create
    if current_user&.role_head?
      @user = User.new(user_params)
      @user.created_by_id = @user.updated_by_id = @user.matchmaker_id = current_user.id
      if @user.save
        render status: 200, json: {user: @user}
      else
        render status: 500, json: {errors: @user.errors}
      end
    else
      render status: 401
    end
  end

  def edit
    if current_user&.role_head? || current_user&.id == @user.matchmaker_id
      user = @user.attributes
      user[:avatar_url] = @user.avatar_url
      render json: {user: user}
    else
      render status: 401
    end
  end

  def update
    if current_user&.role_head? || current_user&.id == @user.id
      p = user_params
      if p[:password].blank? && p[:password_confirmation].blank?
        p.delete(:password)
        p.delete(:password_confirmation)
      end
      @user.assign_attributes(p)
      @user.updated_by_id = current_user.id if @user.changes.present?
      @user.save
      if @user.update(p)
        render status: 200, json: {user: @user}
      else
        render status: 500, json: {errors: @user.errors}
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
    params.fetch(:user, {}).permit(User::REGISTRABLE_ATTRIBUTES)
  end
end
