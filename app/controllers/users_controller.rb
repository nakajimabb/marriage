class UsersController < ApplicationController
  def index
    if current_user.admin?
      render json: {users: User.all}
    else
      render status: 401
    end
  end
end
