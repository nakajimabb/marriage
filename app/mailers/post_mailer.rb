class PostMailer < ApplicationMailer
  def simple_mail(user, subject, body)
    @body = body
    mail(to: user.email, subject: subject)
  end

  def invite(to_user, from_user)
    subject = from_user.full_name + 'さんからのご招待'
    @to_user = to_user
    @from_user = from_user
    @url = 'https://special4.net/'
    mail(to: to_user.email, subject: subject)
  end
end
