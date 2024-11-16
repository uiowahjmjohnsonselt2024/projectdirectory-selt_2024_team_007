class UserMailer < ApplicationMailer
  default from: "no-reply@shardsofthegrid.com"

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password Reset"
  end
end
