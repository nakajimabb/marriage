class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def courtships
    if current_user&.role_matchmaker?
      attrs = current_user.list_attributes
      users = current_user.courtships.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    end
  end

  def index
    if current_user&.role_head?
      attrs = current_user.list_attributes
      users = User.all.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    else
      render status: 401
    end
  end

  def show
    attrs = current_user.list_attributes
    user = attrs.map { |c| [c, @user.try(c)] }.to_h
    render json: {user: user}
  end

  def create
    if current_user&.role_head? || current_user&.role_matchmaker?
      @user = User.new(user_params(nil))
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
      matchmakers = User.where(role_matchmaker: true)
      matchmakers = matchmakers.map{ |user| [:id, :full_name].map { |c| [c, user.try(c)] }.to_h }
      render json: {user: user, matchmakers: matchmakers}
    else
      render status: 401
    end
  end

  def update
    if current_user&.role_head? || current_user&.id == @user.matchmaker_id
      p = user_params(@user)
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

  def user_params(user)
    attrs = current_user.registrable_attributes(user)
    params.fetch(:user, {}).permit(attrs)
  end
end
