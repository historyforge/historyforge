# frozen_string_literal: true

module RecaptchaHandlers
  extend ActiveSupport::Concern

  included do
    before_action :lazy_configure_recaptcha, if: :using_recaptcha?
  end

  private

  def using_recaptcha?
    AppConfig[:recaptcha_site_key].present? && AppConfig[:recaptcha_secret_key].present?
  end

  def lazy_configure_recaptcha
    Recaptcha.configure do |config|
      config.site_key = AppConfig[:recaptcha_site_key]
      config.secret_key = AppConfig[:recaptcha_secret_key]
      config.skip_verify_env = %w[test]
    end
  end
end
