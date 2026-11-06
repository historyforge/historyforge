# frozen_string_literal: true

module People
  module PublicUrlOptions
    def self.call
      base_url = ENV['BASE_URL'].presence
      return {} unless base_url

      origin = URI.parse(base_url.match?(/\Ahttps?:\/\//i) ? base_url : "https://#{base_url}")
      return {} unless origin.host

      { host: origin.host, protocol: origin.scheme, port: origin.port }
    rescue URI::InvalidURIError
      {}
    end
  end
end
