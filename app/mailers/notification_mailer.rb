class NotificationMailer < Devise::Mailer
  default from: 'admin@special4.net'
  include Rails.application.routes.url_helpers

  def reset_password_instructions(record, token, opts={})
    @change_link = change_password_url(token)
    super
  end

  def invite_message(user, from_user)
    @user = user
    @from_user = from_user
    @invitation_link = invitation_url(user.raw_invitation_token)

    subject = I18n.t('devise.mailer.invitation_instructions.subject', name: from_user.full_name)
    mail(:bcc => from_user.email, :to => user.email, :subject => subject)
  end

private

  def invitation_url(token)
    root_url + "#/auth/accept/#{token}"
  end

  def change_password_url(token)
    root_url + "#/auth/change-password/#{token}"
  end
end
