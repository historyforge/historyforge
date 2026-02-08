# frozen_string_literal: true

module Users
  class ReauthenticationController < DeviseController
    include Devise::Passkeys::Controllers::ReauthenticationControllerConcern

    protected

    def relying_party
      WebAuthnHelper.relying_party
    end
  end
end
