# frozen_string_literal: true

module Buildings
  class Geocode
    def self.call(building:)
      new(building:).call
    end

    def initialize(building:)
      @building = building
    end

    MAX_DISTANCE_KM = 50

    def call
      return if Rails.env.test?

      perform_geocoding
      validate_distance_from_locality_center
    rescue Errno::ENETUNREACH
      nil
    end

    private

    attr_reader :building

    def perform_geocoding
      building.geocode
    end

    def validate_distance_from_locality_center
      return unless building.lat.present? && building.lon.present?

      reference_lat, reference_lon = reference_center
      return unless reference_lat.present? && reference_lon.present?

      distance_km = Geocoder::Calculations.distance_between(
        [building.lat, building.lon],
        [reference_lat, reference_lon]
      )

      return unless distance_km > MAX_DISTANCE_KM

      building.lat = reference_lat
      building.lon = reference_lon
    end

    def reference_center
      # First try locality center
      if building.locality&.located?
        return [building.locality.latitude, building.locality.longitude]
      end

      # Fall back to default map center
      default_lat = AppConfig[:latitude]
      default_lon = AppConfig[:longitude]

      if default_lat.present? && default_lon.present?
        return [default_lat, default_lon]
      end

      # No reference center available
      [nil, nil]
    end
  end
end

