# frozen_string_literal: true

class BuildingResidentsLoader
  def initialize(building:, year: nil, filters: nil, reviewed_only: true)
    @building = building
    @year = year
    prepare_filters(filters)
    @reviewed_only = reviewed_only
  end

  attr_reader :building, :year, :filters, :reviewed_only

  def call
    if year
      load_for_year(year)
    else
      CensusYears.map { |year| load_for_year(year).to_a }.flatten
    end
  end

  private

  def load_for_year(year)
    records = building.send("census_#{year}_records")
    records = records.reviewed if reviewed_only
    records = records.ransack(filters).result if filters
    records
  end

  def prepare_filters(filters)
    return if filters.blank?

    @filters = filters.kind_of?(String) ? JSON.parse(filters) : filters
    @filters = @filters.each_with_object({}) {|item, hash|
      hash[item[0].to_sym] = item[1] if item[1].present?
    }
  end
end
