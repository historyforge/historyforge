# frozen_string_literal: true

module Buildings
  # Loads the residents of a building record.
  class FindResidents < ApplicationInteraction
    object :building, class: 'Building'
    integer :year, default: nil
    hash :filters, default: nil
    boolean :reviewed_only, default: true

    def execute
      prepare_filters(filters)

      if year
        load_for_year(year)
      else
        CensusYears.map { |year| load_for_year(year).to_a }.flatten
      end
    end

    private

    def load_for_year(year)
      records = building_for_year(year).send("census#{year}_records")
      records = records.reviewed if reviewed_only
      records = records.ransack(filters).result if filters
      records.in_census_order
    end

    def building_for_year(year)
      building.parent_id && building.hive_year && year < building.hive_year ? building.parent : building
    end

    def prepare_filters(filters)
      return if filters.blank?

      @filters = filters.is_a?(String) ? JSON.parse(filters) : filters
      @filters = @filters.each_with_object({}) do |item, hash|
        hash[item[0].to_sym] = item[1] if item[1].present?
      end
    end
  end
end
