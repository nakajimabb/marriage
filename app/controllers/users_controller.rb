class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :get, :partner_matches, :send_invitation]

  ADDITIONAL_ATTRIBUTES = %i(courtships_size avatar_url identification_url singleness_url revenue_url image_urls)

  def index
    if current_user.role_head?
      attrs = current_user.list_attributes
      users = User.with_attached_avatar
      User::SEARCHABLE_EQ_ATTRIBUTES.each do |attr|
        users = users.where(attr => params[attr]) if params[attr]
      end
      users = users.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
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
        user = @user.attributes
        ADDITIONAL_ATTRIBUTES.each do |attr|
          user[attr] = @user.try(attr)
        end
        render status: 200, json: {user: user}
      else
        render status: 500, json: {errors: @user.errors}
      end
    else
      render status: 401
    end
  end

  def edit
    if current_user.role_head? || current_user.id == @user.matchmaker_id || current_user.id == @user.id
      user = @user.attributes
      ADDITIONAL_ATTRIBUTES.each do |attr|
        user[attr] = @user.try(attr)
      end
      matchmakers = User.where(role_matchmaker: true)
      matchmakers = matchmakers.map{ |user| [:id, :full_name].map { |c| [c, user.try(c)] }.to_h }
      render json: {user: user, matchmakers: matchmakers, user_friend: current_user.user_friend(@user)}
    else
      render status: 401
    end
  end

  def update
    if current_user.role_head? || current_user.id == @user.matchmaker_id || current_user.id == @user.id
      p = user_params(@user)
      if p[:password].blank? && p[:password_confirmation].blank?
        p.delete(:password)
        p.delete(:password_confirmation)
      end
      # TODO: 個別に処理しないと、既存データがクリアされてしまう
      if p[:images].present?
        @user.images.attach(p[:images])
        p.delete(:images)
      end
      @user.assign_attributes(p)
      @user.updated_by_id = current_user.id if @user.changes.present?
      if @user.save
        user = @user.attributes
        ADDITIONAL_ATTRIBUTES.each do |attr|
          user[attr] = @user.try(attr)
        end
        render status: 200, json: {user: user}
      else
        render status: 500, json: {errors: @user.errors}
      end
    else
      render status: 401
    end
  end

  def partner_matches
    if current_user.active? && (current_user.role_head? || (current_user.role_matchmaker? && @user.matchmaker_id == current_user.id))
      attrs = @user.public_attributes
      users = @user.partner_matches.select{ |u| r = u.requirement; (!r || r.matched?(@user)); }
      users = users&.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    else
      render status: 401
    end
  end

  def my_partner_matches
    if current_user.active? && current_user.role_courtship?
      attrs = current_user.public_attributes
      users = current_user.partner_matches  #.select{ |u| r = u.requirement; (!r || r.matched?(current_user)); }
      users = users&.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    else
      render status: 401
    end
  end

  def members
    if current_user.role_matchmaker?
      attrs = current_user.list_attributes
      users = current_user.members
      User::SEARCHABLE_EQ_ATTRIBUTES.each do |attr|
        users = users.where(attr => params[attr]) if params[attr]
      end
      users = users.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    else
      render status: 401
    end
  end

  def matchmakers
    if current_user.role_matchmaker?
      if current_user.active?
        attrs = current_user.list_attributes
        friend_ids = current_user.user_friends.where(status: :accepted).pluck(:companion_id)
        users = User.active.where(role_matchmaker: true)
                    .map{ |user| (attrs.map { |c| [c, user.try(c)] } + [[:friend, friend_ids.include?(user.id)]]).to_h }
      else
        users = User.none
      end
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

  def send_invitation
    if current_user.role_head? || current_user.id == @user.matchmaker_id || current_user.id == @user.id
      PostMailer.invite(@user, current_user).deliver
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
    params.fetch(:user, {}).permit(attrs, images: [])
  end
end
