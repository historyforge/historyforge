# frozen_string_literal: true

module Buildings
  # Loads the residents of a building record.
  class FindResidents
    def self.call(building:, year: nil, filters: nil, user: nil)
      new(building:, year:, filters:, user:).call
    end

    def initialize(building:, year: nil, filters: nil, user: nil)
      @building = building
      @year = year.presence&.to_i
      @filters = filters
      @ability = Ability.new(user)
      @visible_years = CensusYears.visible_to_user(user)
    end

    def call
      prepare_filters(@filters)

      years = year ? @visible_years & [year] : @visible_years
      years.flat_map { |visible_year| load_for_year(visible_year).to_a }
    end

    private

    attr_reader :building, :year

    def load_for_year(year)
      source = building_for_year(year)
      return [] unless source && @ability.can?(:read, source)

      records = source.public_send("census#{year}_records").accessible_by(@ability)
      records = records.ransack(@filters).result if @filters
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
