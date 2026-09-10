# frozen_string_literal: true

settings = { default_url_options: { host: ENV.fetch('BASE_URL', nil) } }

if Rails.env.development?
  settings.merge!(delivery_method: :letter_opener, default_url_options: { host: 'localhost', port: 3000 })
elsif Rails.env.production?
  smtp_settings = {
    address: ENV.fetch('SMTP_HOST', nil),
    port: ENV.fetch('SMTP_PORT', nil),
    user_name: ENV.fetch('SMTP_USERNAME', nil),
    password: ENV.fetch('SMTP_PASSWORD', nil)
  }

  if ENV['SMTP_HOST'] == 'smtp.gmail.com'
    smtp_settings.merge!(authentication: 'plain', enable_starttls: true, open_timeout: 5, read_timeout: 5)
  end

  settings.merge!(delivery_method: :smtp, smtp_settings: smtp_settings)
end

# Keep configuration readers and Action Mailer in sync, even if a gem loaded it early.
Rails.application.config.action_mailer.merge!(settings)
ActiveSupport.on_load(:action_mailer) do
  settings.each { |key, value| public_send("#{key}=", value) }
end
