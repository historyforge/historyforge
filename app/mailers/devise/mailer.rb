# frozen_string_literal: true

class Devise::Mailer < ApplicationMailer
  include Devise::Mailers::Helpers

  def confirmation_instructions(record, token, opts = {})
    @token = token
    devise_mail(record, :confirmation_instructions, mailer_options(opts))
  end

  def reset_password_instructions(record, token, opts = {})
    @token = token
    devise_mail(record, :reset_password_instructions, mailer_options(opts))
  end

  def unlock_instructions(record, token, opts = {})
    @token = token
    devise_mail(record, :unlock_instructions, mailer_options(opts))
  end

  def email_changed(record, opts = {})
    devise_mail(record, :email_changed, mailer_options(opts))
  end

  def password_change(record, opts = {})
    devise_mail(record, :password_change, mailer_options(opts))
  end

  def mailer_options(opts)
    opts.merge from: AppConfig[:mail_from]
  end
end

