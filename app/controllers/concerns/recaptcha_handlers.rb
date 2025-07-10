# frozen_string_literal: true

module RecaptchaHandlers
  extend ActiveSupport::Concern

  included do
    before_action :lazy_configure_recaptcha, if: :using_recaptcha?
    before_action :check_captcha, only: :create, if: :using_recaptcha?
  end

  private

  def check_captcha
    return if verify_recaptcha(action: 'contact', minimum_score: 0.5, secret_key: AppConfig[:recaptcha_secret_key])

    flash[:error] = 'Oops did you fill out the form correctly?'
    render action: :new
  end

  def using_recaptcha?
    AppConfig[:recaptcha_site_key].present? && AppConfig[:recaptcha_secret_key].present?
  end

  def lazy_configure_recaptcha
    Recaptcha.configure do |config|
      config.site_key = AppConfig[:recaptcha_site_key]
      config.secret_key = AppConfig[:recaptcha_secret_key]
    end
  end
end
