class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!, :set_locale

  def set_locale
    I18n.locale = current_user&.lang || I18n.default_locale
  end
end
