class AddressHistoryFromLocalityStreetRenumbering
  include FastMemoize

  def initialize(locality)
    @locality = locality
  end

  def perform
    return unless year

    buildings.each do |building|
      records = residents_of(building)
      addresses = renumbered_addresses_for(building)
      latest_address = records.map { |record| matching_address(addresses, record) }.compact.first
      latest_address&.update(year: year)
    end
  end

  def residents_of(building)
    census_associations.map { |assn| building.send(assn) }.flatten
  end

  def census_years
    CensusYears.gt(year)
  end
  memoize :census_years

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
  memoize :census_associations

  def matching_address(addresses, record)
    addresses.detect do |address|
      address.house_number == record.street_house_number &&
        address.prefix == record.street_prefix &&
        address.suffix == record.street_suffix &&
        address.name   == record.street_name
    end
  end

  def renumbered_addresses_for(building)
    if building.addresses.size == 2
      building.addresses
    else
      counts = {}
      building.addresses.each do |address|
        counts[address.name] ||= 0
        counts[address.name] += 1
      end
      winner = counts.max_by { |k, v| v }[0]
      building.addresses.select { |address| address.name == winner }
    end
  end
end
