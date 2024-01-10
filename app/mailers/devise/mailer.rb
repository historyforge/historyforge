# frozen_string_literal: true

module Devise
  class Mailer < ApplicationMailer
    include Devise::Mailers::Helpers

    default from: proc { "HistoryForge <#{AppConfig[:mail_from]}>" },
            reply_to: proc { "HistoryForge <#{AppConfig[:contact_email]}>" }

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
  end
end

