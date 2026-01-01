# frozen_string_literal: true

module Buildings
  class Geocode < ApplicationInteraction
    object :building, class: 'Building'

    MAX_DISTANCE_KM = 50

    def execute
      return if Rails.env.test?

      perform_geocoding
      validate_distance_from_locality_center
    rescue Errno::ENETUNREACH
      nil
    end

    private

    def perform_geocoding
      building.geocode
    end

    def validate_distance_from_locality_center
      return unless building.lat.present? && building.lon.present?
      return unless building.locality&.located?

      distance_km = Geocoder::Calculations.distance_between(
        [building.lat, building.lon],
        [building.locality.latitude, building.locality.longitude]
      )

      return unless distance_km > MAX_DISTANCE_KM

      building.lat = building.locality.latitude
      building.lon = building.locality.longitude
    end
  end
end

