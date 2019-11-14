class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :get]

  def members
    if current_user.role_matchmaker?
      attrs = current_user.list_attributes
      users = current_user.members.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    else
      render status: 401
    end
  end

  def matchmakers
    if current_user.role_matchmaker?
      attrs = current_user.list_attributes
      friend_ids = current_user.user_friends.where(status: :accepted).pluck(:companion_id)
      users = User.where(role_matchmaker: true)
                  .map{ |user| (attrs.map { |c| [c, user.try(c)] } + [[:friend, friend_ids.include?(user.id)]]).to_h }
      render json: {users: users}
    else
      render status: 401
    end
  end

  def viewable
    if current_user.role_matchmaker?
      attrs = current_user.public_attributes
      matchmaker_ids = User.where(role_matchmaker: true, member_sharing: :member_public).pluck(:id)
      matchmaker_ids += current_user.user_friends.pluck(:companion_id)
      matchmaker_ids.delete(current_user.id)
      matchmaker_ids.uniq!
      users = User.where(role_courtship: true, matchmaker_id: matchmaker_ids)
      users = users.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    else
      render status: 401
    end
  end

  def index
    if current_user.role_head?
      attrs = current_user.list_attributes
      users = User.all.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    else
      render status: 401
    end
  end

  def show
    attrs = current_user.public_attributes
    user = attrs.map { |c| [c, @user.try(c)] }.to_h
    render json: {user: user, user_friend: current_user.user_friend(@user)}
  end

  def get
    if current_user.role_head? || (current_user.role_matchmaker? && current_user.id == @user.matchmaker_id)
      user = @user.attributes
      user[:age] = @user.age
      user[:avatar_url] = @user.avatar_url
    else
      attrs = current_user.public_attributes
      user = attrs.map { |c| [c, @user.try(c)] }.to_h
    end
    render json: {user: user, user_friend: current_user.user_friend(@user)}
  end

  def create
    if current_user.role_head? || current_user.role_matchmaker?
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
    if current_user.role_head? || current_user.id == @user.matchmaker_id
      user = @user.attributes
      user[:courtships_size] = @user.courtships_size
      user[:avatar_url] = @user.avatar_url
      matchmakers = User.where(role_matchmaker: true)
      matchmakers = matchmakers.map{ |user| [:id, :full_name].map { |c| [c, user.try(c)] }.to_h }
      render json: {user: user, matchmakers: matchmakers, user_friend: current_user.user_friend(@user)}
    else
      render status: 401
    end
  end

  def update
    if current_user.role_head? || current_user.id == @user.matchmaker_id
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

  def update_self
    p = user_params(current_user)
    if p[:password].blank? && p[:password_confirmation].blank?
      p.delete(:password)
      p.delete(:password_confirmation)
    end
    if current_user.update(p)
      render status: 200, json: {user: current_user}
    else
      render status: 500, json: {errors: current_user.errors}
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
