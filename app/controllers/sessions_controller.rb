# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, if: :json_request?
  respond_to :html, :json

  def destroy
    if current_user != true_user
      stop_impersonating_user
      redirect_to users_path
    else
      super
    end
  end

  protected

  def json_request?
    request.format.json?
  end
end
