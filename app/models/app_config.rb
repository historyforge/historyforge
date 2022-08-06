# frozen_string_literal: true

# Provides application configuration values. Mostly a facade for Setting.
class AppConfig
  def self.[](key)
    Setting.load unless Setting.loaded?
    ENV[key.to_s.upcase] || Setting.value_of(key)
  end
end
