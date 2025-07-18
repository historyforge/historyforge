# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.application.config.allowed_cors_origins

    resource '/api/*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             expose: %w[Content-Length Content-Type]

    resource '/admin/api/*',
             headers: :any,
             methods: %i[get post options head],
             expose: %w[Content-Length Content-Type]
  end
end
