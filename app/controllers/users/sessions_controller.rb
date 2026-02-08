# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    include Devise::Passkeys::Controllers::SessionsControllerConcern

    skip_before_action :verify_authenticity_token, if: :json_request?
    respond_to :html, :json

    def create
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)

      respond_to do |format|
        format.json do
          render json: { success: true, redirect_url: after_sign_in_path_for(resource) }, status: :ok
        end
        format.html { respond_with resource, location: after_sign_in_path_for(resource) }
      end
    rescue => e
      if json_request?
        render json: { error: 'Authentication failed', message: e.message }, status: :unauthorized
      else
        raise
      end
    end

    def destroy
      if current_user == true_user
        super
      else
        stop_impersonating_user
        redirect_to users_path
      end
    end

    # Override to support Conditional UI (discoverable credentials)
    def new_challenge
      options_for_authentication = generate_authentication_options(
        relying_party: relying_party,
        options: { user_verification: 'preferred', allow_credentials: nil }
      )

      store_challenge_in_session(options_for_authentication: options_for_authentication)

      render json: options_for_authentication
    end

    protected

    def json_request?
      request.format.json? || request.content_type&.include?('application/json')
    end

    def relying_party
      WebAuthnHelper.relying_party
    end
  end
end
