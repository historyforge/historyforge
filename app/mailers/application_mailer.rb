# frozen_string_literal: true

# Base class for all mailers
class ApplicationMailer < ActionMailer::Base
  default from: AppConfig.mail_from
end
