# frozen_string_literal: true

module Api
  class SearchController < ApplicationController
    include EntityBuilders
    include SearchService
    include CorsHandler

    protect_from_forgery with: :null_session, if: :cors_request?

    def search
      return if handle_cors_preflight

      search_term = params[:search]
      return render_empty_geojson if search_term.blank?

      features = build_geojson_features(search_term)
      geojson = Building.as_geojson(features)

      set_cors_headers
      render json: geojson
    end

    private

    def build_geojson_features(search_term)
      all_features = []

      SEARCH_YEARS.each do |year|
        buildings = search_buildings(search_term, year, require_coordinates: true)
        features = buildings.filter_map { |building| build_geojson_feature(building, year) }
        all_features.concat(features)
      end

      all_features.flatten
    end

    def build_geojson_feature(building, year)
      return nil unless building&.latitude&.nonzero? && building&.longitude&.nonzero?

      # Apply strict mode filtering
      if strict_mode?
        census_records = get_census_records_for_building(building, year)
        people = get_people_for_building(building, year)
        return nil unless census_records.any? || people.any?
      end

      # Build the enhanced building hash
      building_hash = build_building_hash(building, year)
      return nil if building_hash.nil?

      # Set up instance variables and singleton methods for backward compatibility
      setup_building_compatibility(building, building_hash, year)

      building
    end

    def setup_building_compatibility(building, building_hash, year)

      # Set up instance variables exactly like v1
      create_instance_variables(building, year, building_hash)

      # Set up singleton methods exactly like v1
      create_singleton_methods(building, year, building_hash)
    end

    def create_instance_variables(building, year, building_hash)
      building.instance_variable_set(:@census_records, building_hash[:properties][:census_records])
      building.instance_variable_set(:@people, building_hash[:properties][:people])
      building.instance_variable_set(:@year, year)
      building.instance_variable_set(:@building_narratives, building_hash[:properties][:narratives])
      building.instance_variable_set(:@building_photos, building_hash[:properties][:photos])
      building.instance_variable_set(:@building_audios, building_hash[:properties][:audios])
      building.instance_variable_set(:@building_videos, building_hash[:properties][:videos])
      building.instance_variable_set(:@building_documents, building_hash[:properties][:documents])
    end

    def create_singleton_methods(building, year, building_hash)
      building.define_singleton_method(:building_people) { building_hash[:properties][:people] }
      building.define_singleton_method(:building_census) { building_hash[:properties][:census_records] }
      building.define_singleton_method(:year) { year }
      building.define_singleton_method(:building_narratives) { building_hash[:properties][:narratives] }
      building.define_singleton_method(:building_photos) { building_hash[:properties][:photos] }
      building.define_singleton_method(:building_audios) { building_hash[:properties][:audios] }
      building.define_singleton_method(:building_videos) { building_hash[:properties][:videos] }
      building.define_singleton_method(:building_documents) { building_hash[:properties][:documents] }
    end

    def strict_mode?
      params[:strict] != 'false'
    end

    def should_skip_empty_census?
      strict_mode?
    end

    def render_empty_geojson
      set_cors_headers
      render json: { type: 'FeatureCollection', features: [] }
    end
  end
end
