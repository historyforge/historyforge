# frozen_string_literal: true

# Provides application configuration values. Mostly a facade for Setting.
class AppConfig
  def self.[](key)
    Setting.load unless Setting.loaded?
    Setting.value_of(key) || ENV.fetch(key.to_s.upcase, nil)
  end

  # Returns the sanitized app name for use as Google Maps API channel parameter
  # Channel parameter must be alphanumeric with underscores only
  # Defaults to "historyforge" if app_name is not set
  # This value is precalculated and cached
  def self.google_maps_channel
    app_name = self[:app_name].presence || 'historyforge'

    @google_maps_channel ||= begin
      app_name.to_s
        .downcase
        .gsub(/[^a-z0-9_]/, '_')  # Replace non-alphanumeric (except _) with _
        .gsub(/_+/, '_')            # Replace multiple underscores with single underscore
        .gsub(/^_|_$/, '')          # Remove leading/trailing underscores
        .presence || 'historyforge'  # Fallback to historyforge if result is blank
    end
  end
end
