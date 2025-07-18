# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.application.config.allowed_cors_origins

    resource '/api/*',
             headers: %w[Accept Accept-Language Cache-Control Connection DNT Origin
                        Pragma Referer Sec-Fetch-Dest Sec-Fetch-Mode Sec-Fetch-Site
                        User-Agent sec-ch-ua sec-ch-ua-mobile sec-ch-ua-platform
                        Content-Type Authorization X-Requested-With],
             methods: %w[GET POST OPTIONS],
             max_age: 86400
  end
end
