module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    before_action :authenticate_user!, :except => [:new, :create, :destroy]
  end
end
