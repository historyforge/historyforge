# frozen_string_literal: true

module Api
  class SearchController < ApplicationController
    include EntityBuilders
    include SearchService

    def search

      search_term = params[:search]
      return render_empty_geojson if search_term.blank?

      features = build_geojson_features(search_term)
      geojson = BuildingEntity.to_geojson(features)

      render json: geojson
    end

    private

    def build_geojson_features(search_term)
      all_features = []

      SEARCH_YEARS.each do |year|
        buildings = search_buildings(search_term, year, require_coordinates: true)
        entities = buildings.filter_map { |building| build_building_entity(building, year) }
        all_features.concat(entities)
      end

      all_features.flatten
    end

    def build_building_entity(building, year)
      return nil unless building&.latitude&.nonzero? && building&.longitude&.nonzero?

      # Apply strict mode filtering
      if strict_mode?
        census_records = BaseEntity.get_census_records_for_building(building, year)
        people = BaseEntity.get_people_for_building(building, year)
        return nil unless census_records.any? || people.any?
      end

      # Build the BuildingEntity
      BuildingEntity.build_from(building, year, include_related: true)
    end

    def strict_mode?
      params[:strict] != 'false'
    end

    def should_skip_empty_census?
      strict_mode?
    end

    def render_empty_geojson
      render json: { type: 'FeatureCollection', features: [] }
    end
  end
end
