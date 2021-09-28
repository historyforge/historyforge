class UserMailer < ActionMailer::Base
  def disabled_change_password(user)
    @user = user
    @subject = "#{ENV['APP_NAME']} You account is disabled until you change your password"
    mail(to: @user.email, subject: @subject)
  end

  def new_registration(user)
    @user = user
    @subject = "Welcome to #{ENV['APP_NAME']} #{@user.login}"
    mail(to: @user.email, subject: @subject)
  end

end
