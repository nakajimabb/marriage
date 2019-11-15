class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :get, :partner_matches]

  def partner_matches
    if current_user.role_head? || (current_user.role_matchmaker? && @user.matchmaker_id == current_user.id)
      attrs = current_user.public_attributes
      users = @user.partner_matches
      users = users&.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
      if users
        users.each do |user|
          eval_partner = @user.eval_partners.find_by(partner_id: user[:id])
          user[:permitted] = eval_partner&.permitted
          user[:requirement_score] = eval_partner&.requirement_score
        end
      end
      render json: {users: users}
    else
      render status: 401
    end
  end

  def permitted_users
    if current_user.role_courtship?
      attrs = current_user.public_attributes
      partner_ids = current_user.eval_partners.where(permitted: true).pluck(:partner_id)
      sex = current_user.male? ? :female : :male
      users = User.where(id: partner_ids, sex: sex, role_courtship: true)
      users = users&.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    else
      render status: 401
    end
  end

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
      users = current_user.viewables
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
      if @user.save
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
