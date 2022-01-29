class AddressHistoryFromLocalityStreetRenumbering
  include FastMemoize

  def initialize(locality)
    @locality = locality
  end

  def perform
    return unless year

    buildings.each do |building|
      BuildAddressHistory.new(building, year:).perform
    end
  end

  def year
    @locality.year_street_renumber
  end
  memoize :year

  def buildings
    @locality
      .buildings
      .with_multiple_addresses
      .preload(:addresses)
      .preload(*census_associations)
  end

  def census_associations
    census_years.map { |y| "census_#{y}_records" }
  end

  def census_years
    CensusYears.gt(year)
  end
end
