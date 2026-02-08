# frozen_string_literal: true

require 'webauthn'

# Configure WebAuthn Relying Party
# These values should be set via environment variables
# WEBAUTHN_ORIGIN: The origin URL (e.g., https://yourdomain.com)
# WEBAUTHN_RP_ID: The relying party ID (typically the domain name without protocol)
module WebAuthnHelper
  def self.relying_party
    origin = build_origin
    rp_id = ENV.fetch('WEBAUTHN_RP_ID') { extract_rp_id(ENV['BASE_URL'] || origin) }

    WebAuthn::RelyingParty.new(
      allowed_origins: [origin],
      name: 'HistoryForge',
      id: rp_id
    )
  end

  def self.build_origin
    if ENV['WEBAUTHN_ORIGIN'].present?
      ENV['WEBAUTHN_ORIGIN']
    elsif ENV['BASE_URL'].present?
      # Prepend http:// or https:// to BASE_URL to get the origin
      base_url = ENV['BASE_URL']
      if base_url.start_with?('http://', 'https://')
        base_url
      else
        # Use http for localhost, https otherwise
        protocol = base_url.include?('localhost') ? 'http' : 'https'
        "#{protocol}://#{base_url}"
      end
    else
      # Build from action_mailer config or use request
      default_options = Rails.application.config.action_mailer.default_url_options || {}
      host = default_options[:host] || 'localhost'
      protocol = default_options[:protocol] || (Rails.env.production? ? 'https' : 'http')
      port = default_options[:port]

      origin = "#{protocol}://#{host}"
      origin += ":#{port}" if port && port != 80 && port != 443
      origin
    end
  end

  def self.extract_rp_id(url)
    return 'localhost' if url.blank?

    # If URL doesn't have a protocol, add one temporarily for parsing
    url_to_parse = url.start_with?('http://', 'https://') ? url : "https://#{url}"
    uri = URI.parse(url_to_parse)
    uri.host || 'localhost'
  rescue URI::InvalidURIError
    'localhost'
  end
end
