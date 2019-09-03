class UsersController < ApplicationController
  def index
    render json: {users: User.all}
  end
end
