# frozen_string_literal: true

allowed_origins = ENV.fetch('API_CORS_ORIGINS', '').split(',').map(&:strip).reject(&:empty?)

if allowed_origins.any?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins { |origin| allowed_origins.include?(origin) }
      resource %r{\A/api/v1/people/\d+(?:\.json)?\z}, methods: %i[get head], headers: %w[Content-Type]
    end
  end
end
