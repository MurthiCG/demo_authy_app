class ApplicationMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers
  
  default from: 'from@example.com'
  layout 'mailer'

  def send_confirmation_email(user)
    @user = user
    mail(
      to: user.email,
      subject: "Regstration Confirmation"
    )
  end

  def send_otp(user, otp)
    @user = user
    @otp = otp
    mail(
      to: user.email,
      subject: "One Time Password to login"
    )
  end
end
