class PostMailer < ApplicationMailer
  def simple_mail(user, subject, body)
    @body = body
    mail(to: user.email, subject: subject)
  end
end
