# frozen_string_literal: true

module Users
  class PasskeysController < DeviseController
    before_action :authenticate_user!
    include Devise::Passkeys::Controllers::PasskeysControllerConcern

    skip_before_action :verify_authenticity_token, if: :json_request?
    skip_before_action :verify_reauthentication_token, 
      only: [:create], 
      if: -> { current_user.passkeys.empty? }
    before_action :ensure_user_owns_passkey, only: [:destroy]
    
    # Override to handle credential parsing errors gracefully
    rescue_from StandardError, with: :handle_credential_error

    # Override create_passkey to handle JSON responses properly
    def create_passkey(resource:)
      passkey = resource.passkeys.create!(
        label: passkey_params[:label],
        public_key: @webauthn_credential.public_key,
        external_id: Base64.strict_encode64(@webauthn_credential.raw_id),
        sign_count: @webauthn_credential.sign_count,
        last_used_at: nil
      )
      yield [resource, passkey] if block_given?
      
      respond_to do |format|
        format.json { render json: { success: true, passkey: { id: passkey.id, label: passkey.label } }, status: :created }
        format.html { redirect_to users_passkeys_path }
      end
    end

    # Override new_create_challenge to ensure proper format
    def new_create_challenge
      # Ensure user has webauthn_id
      current_user.generate_webauthn_id if current_user.webauthn_id.blank?
      current_user.save if current_user.changed?

      challenge = WebAuthn::Credential.options_for_create(
        user: {
          id: current_user.webauthn_id,
          name: current_user.email,
          display_name: current_user.login
        },
        exclude: current_user.passkeys.pluck(:external_id).map { |id| Base64.strict_decode64(id) },
        relying_party:
      )

      # Store challenge in session using the concern's method
      # This ensures it's stored at the correct key that verify_registration expects
      store_challenge_in_session(options_for_registration: challenge)

      # Ensure the challenge includes the rp object with name and id
      challenge_hash = challenge.as_json
      challenge_hash['rp'] ||= {}
      challenge_hash['rp']['name'] ||= relying_party.name
      challenge_hash['rp']['id'] ||= relying_party.id

      render json: challenge_hash
    end

    protected

    def relying_party
      WebAuthnHelper.relying_party
    end

    def json_request?
      request.format.json? || request.content_type&.include?('application/json')
    end

    private

    def ensure_user_owns_passkey
      passkey = Passkey.find(params[:id])
      unless passkey.user == current_user
        flash[:error] = 'You can only manage your own passkeys.'
        redirect_to users_passkeys_path
      end
    end

    def handle_credential_error(exception)
      respond_to do |format|
        format.json do
          render json: { 
            error: 'Failed to process passkey credential',
            message: exception.message 
          }, status: :unprocessable_entity
        end
        format.html do
          flash[:error] = 'Failed to register passkey. Please try again.'
          redirect_to users_passkeys_path
        end
      end
    end
  end
end
