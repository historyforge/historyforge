# frozen_string_literal: true

# Sends the email from the contact form
class ContactMailer < ApplicationMailer
  def contact_email(contact)
    @contact = contact
    mail subject: "[HISTORYFORGE] #{@contact.subject}",
         to: AppConfig.contact_email,
         reply_to: @contact.email
  end
end
