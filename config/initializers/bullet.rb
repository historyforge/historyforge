# frozen_string_literal: true

# Opt in before Bundler loads gems: BULLET=1 bin/dev or BULLET=1 bin/check.
if defined?(Bullet) && (Rails.env.development? || Rails.env.test?)
  Rails.application.config.after_initialize do
    Bullet.enable = true
    Bullet.alert = false
    Bullet.bullet_logger = true
    Bullet.console = false
    Bullet.rails_logger = false
    Bullet.add_footer = Rails.env.development?
  end
end
