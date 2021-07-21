if defined?(Airbrake) && ENV['AIRBRAKE_ID']
  Airbrake.configure do |config|
    config.project_id = ENV['AIRBRAKE_ID'] || 1
    config.project_key = ENV['AIRBRAKE_KEY']
    config.host = ENV['AIRBRAKE_URL']
    config.environment = Rails.env
    config.ignore_environments = %w[development test]
  end

  IGNORED_ERRORS = %w[
    ActionController::InvalidAuthenticityToken
    ActiveRecord::RecordNotFound
    AbstractController::ActionNotFound
    SIGTERM
    SIGQUIT
  ].freeze
  Airbrake.add_filter do |notice|
    notice.ignore! if notice[:errors].any? { |error| IGNORED_ERRORS.include? error[:type] }
  end

  if Airbrake.const_defined?('SENSITIVE_RACK_VARS')
    %w[
      SENSITIVE_RACK_VARS
      RACK_VARS_CONTAINING_INSTANCES
      SENSITIVE_ENV_VARS
      FILTERED_RACK_VARS].each do |name|
      Airbrake.send :remove_const, name.to_sym
    end
  end

  module Airbrake
    SENSITIVE_RACK_VARS = %w[
      HTTP_X_CSRF_TOKEN
      HTTP_COOKIE

      action_dispatch.request.unsigned_session_cookie
      action_dispatch.cookies
      action_dispatch.unsigned_session_cookie
      action_dispatch.secret_key_base
      action_dispatch.signed_cookie_salt
      action_dispatch.encrypted_cookie_salt
      action_dispatch.encrypted_signed_cookie_salt
      action_dispatch.http_auth_salt
      action_dispatch.secret_token

      rack.request.cookie_hash
      rack.request.cookie_string
      rack.request.form_vars

      rack.session
      rack.session.options
  ].freeze

    RACK_VARS_CONTAINING_INSTANCES = %w[
      action_controller.instance

      action_dispatch.backtrace_cleaner
      action_dispatch.routes
      action_dispatch.logger
      action_dispatch.key_generator

      rack-cache.storage

      rack.errors
      rack.input
  ].freeze

    SENSITIVE_ENV_VARS = [
        /database_url/i,
        /encryption_key/i,
        /pepper/i,
        /aws/i,
        /twilio/i,
        /secret/i,
        /password/i,
        /twitter/i,
        /token/i,
        /api/i
    ].freeze

    FILTERED_RACK_VARS = SENSITIVE_RACK_VARS + SENSITIVE_ENV_VARS + RACK_VARS_CONTAINING_INSTANCES
  end


end
