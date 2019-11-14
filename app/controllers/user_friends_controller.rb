class UserFriendsController < ApplicationController
  before_action :set_user_friend, only: [:destroy, :accept_request]

  def waiting_friends
    if current_user.role_matchmaker?
      user_friends = UserFriend.where(companion_id: current_user.id, status: :waiting)
      attrs = [:id, :user_id, :user_name, :user_avatar_url]
      user_friends = user_friends.map{ |uf| attrs.map { |c| [c, uf.try(c)] }.to_h }
      render status: 200, json: {user_friends: user_friends}
    else
      render status: 200, json: {user_friends: []}
    end
  end

  def request_sharing
    if current_user.role_matchmaker?
      companion = User.find_by_id(params[:companion_id])
      if companion && companion.role_matchmaker? && companion.id != current_user.id
        user_friend = UserFriend.find_or_initialize_by(user_id: current_user.id, companion_id: companion.id)
        user_friend.status = :waiting
        if user_friend.new_record? && user_friend.save
          render status: 200, json: {user_friend: user_friend}
        else
          render status: 500
        end
      else
        render status: 500
      end
    else
      render status: 401
    end
  end

  def accept_request
    if @user_friend.waiting? && @user_friend.companion_id == current_user.id
      UserFriend.transaction do
        @user_friend.update(user_friend_params)
        user_friend = UserFriend.find_or_initialize_by(user_id: @user_friend.companion_id, companion_id: @user_friend.user_id)
        if @user_friend.accepted?
          user_friend.status = :accepted
          user_friend.save
        else
          user_friend.delete
        end
      end
      user_friends = UserFriend.where(companion_id: current_user.id, status: :waiting)
      render status: 200, json: {user_friend: @user_friend, user_friends: user_friends}
    else
      render status: 401
    end
  end

private

  def set_user_friend
    @user_friend = UserFriend.find(params[:id])
  end

  def user_friend_params
    params.fetch(:user_friend, {}).permit(:status)
  end
end
