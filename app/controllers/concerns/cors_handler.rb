# frozen_string_literal: true

module CorsHandler
  extend ActiveSupport::Concern

  def handle_cors_preflight
    if request.method == 'OPTIONS'
      set_cors_headers
      head :ok
      return true
    end
    false
  end

  def set_cors_headers
    origin = request.headers['Origin']
    allowed_origins = Rails.application.config.allowed_cors_origins

    if origin.present? && (allowed_origins.include?(origin) || allowed_origins.include?('*'))
      response.headers['Access-Control-Allow-Origin'] = origin
    elsif allowed_origins.include?('*')
      response.headers['Access-Control-Allow-Origin'] = '*'
    end

    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Accept, Accept-Language, Cache-Control, Connection, DNT, Origin, Pragma, Referer, Sec-Fetch-Dest, Sec-Fetch-Mode, Sec-Fetch-Site, User-Agent, sec-ch-ua, sec-ch-ua-mobile, sec-ch-ua-platform, Content-Type, Authorization, X-Requested-With'
    response.headers['Access-Control-Max-Age'] = '86400'
    response.headers['Vary'] = 'Origin'
  end

  private

  def cors_request?
    origin = request.headers['Origin']
    allowed_origins = Rails.application.config.allowed_cors_origins
    origin.present? && (allowed_origins.include?(origin) || allowed_origins.include?('*'))
  end
end
