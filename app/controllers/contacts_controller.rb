# frozen_string_literal: true

class ContactsController < ApplicationController
  before_action :lazy_configure_recaptcha

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new params.require(:contact).permit(:name, :email, :subject, :phone, :message, :organization, :how_heard)
    if verify_recaptcha(action: 'contact', minimum_score: 0.5, secret_key: AppConfig[:recaptcha_secret_key]) && @contact.save
      ContactMailer.contact_email(@contact).deliver_now
      flash[:notice] = 'Thanks! Your message has been sent.'
      redirect_to root_path
    else
      flash[:error] = 'Oops did you fill out the form correctly?'
      render action: :new
    end
  end

  def lazy_configure_recaptcha
    Recaptcha.configure do |config|
      config.site_key = AppConfig[:recaptcha_site_key]
      config.secret_key = AppConfig[:recaptcha_secret_key]
    end
  end
end
