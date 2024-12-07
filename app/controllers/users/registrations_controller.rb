# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    # rubocop:disable Rails/LexicallyScopedActionFilter
    prepend_before_action :check_captcha, only: :create
    prepend_before_action :lazy_configure_recaptcha

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    # def create
    #   super
    # end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_up_params
    #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
    # end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end

    private

    def sign_up_params
      params.require(:user).permit(:login, :email, :password, :password_confirmation)
    end

    def account_update_params
      params.require(:user).permit(:password, :password_confirmation, :current_password)
    end

    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [:login])
    end

    def lazy_configure_recaptcha
      Recaptcha.configure do |config|
        config.site_key = AppConfig[:recaptcha_site_key]
        config.secret_key = AppConfig[:recaptcha_secret_key]
      end
    end

    def check_captcha
      self.resource = resource_class.new sign_up_params
      return if !Rails.env.production? || recaptcha_verified?

      resource.validate # Look for any other validation errors besides reCAPTCHA

      set_minimum_password_length
      respond_with_navigational(resource) do
        flash.discard(:recaptcha_error) # We need to discard flash to avoid showing it on the next page reload
        render :new
      end
    end

    def recaptcha_verified?
      verify_recaptcha(action: 'registration', minimum_score: 0.5, secret_key: AppConfig[:recaptcha_secret_key])
    end
  end
end
