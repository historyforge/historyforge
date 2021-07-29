# frozen_string_literal: true

# Provides application configuration values. Mostly a facade for Setting.
class AppConfig
  def self.[](key)
    ENV[key.to_s.upcase] || Setting.value_of(key)
  end

  # So that you can do AppConfig.whatever_key and it will go to the self.[] method
  def self.method_missing(method, *_args)
    self[method]
  end

  def self.respond_to_missing?(_method)
    true
  end
end
