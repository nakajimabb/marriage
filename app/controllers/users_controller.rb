class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :get, :partner_matches, :send_invitation]
  before_action :authenticate_user!, :except => [:accept, :reset_password, :send_reset_password, :home]

  ADDITIONAL_ATTRIBUTES = %i(courtships_size avatar_url identification_url singleness_url revenue_url image_urls)

  def home
    render plain: root_url
  end

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
        render json: {user: user}
      else
        render status: 500, json: {errors: @user.errors}
      end
    else
      render json: {users: User.none}
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
        render json: {user: user}
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
      render json: {users: User.none}
    end
  end

  def my_partner_matches
    if current_user.active? && current_user.role_courtship?
      attrs = current_user.public_attributes
      users = current_user.partner_matches  #.select{ |u| r = u.requirement; (!r || r.matched?(current_user)); }
      users = users&.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    else
      render json: {users: User.none}
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
      render json: {users: User.none}
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
      render json: {users: User.none}
    end
  end

  def viewable
    if current_user.role_matchmaker?
      attrs = current_user.public_attributes
      users = current_user.viewables
      users = users.map{ |user| attrs.map { |c| [c, user.try(c)] }.to_h }
      render json: {users: users}
    else
      render json: {users: User.none}
    end
  end

  def invite
    if current_user.role_head? || current_user.role_matchmaker?
      begin
        attrs = { email: params[:email], sex: params[:sex] }
        if current_user.role_head?
          attrs[:role_matchmaker] = params[:role_matchmaker]
        end
        if params[:role_courtship].present?
          attrs[:role_courtship] = params[:role_courtship]
          attrs[:matchmaker_id] = current_user.id
        end
        user = User.invite!(attrs.compact, current_user) do |u|
          u.skip_invitation = true
        end
        if user.errors.empty?
          NotificationMailer.invite_message(user, current_user).deliver
          user.update_column(:invitation_sent_at, Time.now.utc)
          render json: {user: user}
        else
          render status: 500, json: {error: user.errors.full_messages.join(', ')}
        end
      rescue => e
        render status: 503, json: {error: e.message}
      end
    else
      render status: 401
    end
  end

  def accept
    if params[:invitation_token].present? && params[:password].present? && params[:password_confirmation].present?
      user = User.find_by_invitation_token(params[:invitation_token], true)
      if user
        user = User.accept_invitation!(invitation_token: params[:invitation_token],
                                       password: params[:password],
                                       password_confirmation: params[:password_confirmation])
        if user.valid?
          render json: {user: user}
        else
          render status: 500, json: {error: user.errors.full_messages.join(', ')}
        end
      else
        render status: 500, json: {error: I18n.t('errors.user.invalid_token')}
      end
    else
      render status: 401
    end
  end

  def send_reset_password
    if params[:email].present?
      begin
        user = User.find_by_email(params[:email])
        if user
          user.send_reset_password_instructions
        else
          render status: 500, json: {error: I18n.t('errors.user.mail_not_exist')}
        end
      rescue => e
        render status: 503, json: {error: e.message}
      end
    else
      render status: 401
    end
  end

  def reset_password
    if params[:reset_password_token].present? && params[:password].present? && params[:password_confirmation].present?
      user = User.with_reset_password_token(params[:reset_password_token])
      if user
        user = User.reset_password_by_token(reset_password_token: params[:reset_password_token],
                                            password: params[:password],
                                            password_confirmation: params[:password_confirmation])

        if user.valid?
          render json: {user: user}
        else
          render status: 500, json: {error: user.errors.full_messages.join(', ')}
        end
      else
        render status: 500, json: {error: I18n.t('errors.user.invalid_token')}
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
    params.fetch(:user, {}).permit(attrs, images: [])
  end
end
