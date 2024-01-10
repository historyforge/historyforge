# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def disabled_change_password(user)
    @user = user
    @subject = "#{ENV['APP_NAME']} Your account is disabled until you change your password"
    mail(to: @user.email, subject: @subject, from: AppConfig[:mail_from])
  end

  def new_registration(user)
    @user = user
    @subject = "Welcome to #{ENV['APP_NAME']} #{@user.login}"
    mail(to: @user.email, subject: @subject, from: AppConfig[:mail_from])
  end

end
