# frozen_string_literal: true

class VolunteerApplicationMailer < ApplicationMailer
  def application_email(application)
    @application = application
    mail subject: '[HISTORYFORGE] New volunteer application',
         to: AppConfig[:contact_email],
         reply_to: @application.email,
         from: AppConfig[:mail_from]
  end
end
