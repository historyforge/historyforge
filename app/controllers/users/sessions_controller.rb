# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    skip_before_action :verify_authenticity_token, if: :json_request?
    respond_to :html, :json

    def create
      self.resource = warden.authenticate!(auth_options)
      raise resource.inspect
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end

    def destroy
      if current_user == true_user
        super
      else
        stop_impersonating_user
        redirect_to users_path
      end
    end

    protected

    def json_request?
      request.format.json?
    end
  end
end
