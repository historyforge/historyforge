class ContactMailer < ApplicationMailer
  def contact_email(contact)
    @contact = contact
    mail from: AppConfig.mail_from,
         subject: "[HISTORYFORGE] #{@contact.subject}",
         to: AppConfig.contact_email,
         reply_to: @contact.email
  end
end
