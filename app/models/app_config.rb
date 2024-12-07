# frozen_string_literal: true

# Provides application configuration values. Mostly a facade for Setting.
class AppConfig
  def self.[](key)
    Setting.load unless Setting.loaded?
    Setting.value_of(key) || ENV.fetch(key.to_s.upcase, nil)
  end
end
