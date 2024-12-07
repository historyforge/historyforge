# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    prepend_before_action :check_captcha, only: :create
    prepend_before_action :lazy_configure_recaptcha

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    def create
      build_resource(sign_up_params)
      # Devise create method is overridden so that we can do this, which tells it to require a password.
      resource.public_signup = true
      resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end

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

    private

    def sign_up_params
      params.require(:user).permit(:login, :email, :password, :password_confirmation)
    end

    def lazy_configure_recaptcha
      Recaptcha.configure do |config|
        config.site_key = AppConfig[:recaptcha_site_key]
        config.secret_key = AppConfig[:recaptcha_secret_key]
        config.skip_verify_env = %w[test]
      end
    end

    def check_captcha
      self.resource = resource_class.new sign_up_params
      return if recaptcha_verified?

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
