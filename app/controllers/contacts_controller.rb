# frozen_string_literal: true

class ContactsController < ApplicationController
  include RecaptchaHandlers

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new params.require(:contact).permit(:name, :email, :subject, :phone, :message, :organization, :how_heard)
    if check_captcha && @contact.save
      ContactMailer.contact_email(@contact).deliver_now
      flash[:notice] = "Thanks! Your message has been sent."
      redirect_to root_path
    else
      flash[:error] = "Oops did you fill out the form correctly?"
      render action: :new
    end
  end

  def check_captcha
    return true unless using_recaptcha?

    verify_recaptcha(action: "contact", minimum_score: 0.5, secret_key: AppConfig[:recaptcha_secret_key])
  end
end
