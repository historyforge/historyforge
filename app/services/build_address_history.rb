# frozen_string_literal: true

class BuildAddressHistory
  include FastMemoize

  def initialize(building, year: nil)
    @building = building
    @year = year || @building.locality&.year_street_renumber
  end

  attr_reader :building, :year

  def perform
    return unless year

    addresses = renumbered_addresses_for(building)
    return unless addresses

    latest_address = residents_of(building).filter_map { |record| matching_address(addresses, record) }.first
    return unless latest_address
    return if latest_address.year

    latest_address.update(year:)
  end

  def residents_of(building)
    census_associations.map { |assn| building.send(assn) }.flatten
  end

  def census_years
    CensusYears.gt(year)
  end
  memoize :census_years

  def census_associations
    census_years.map { |y| "census#{y}_records" }
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
    counts = {}
    building.addresses.each do |address|
      counts[address.name] ||= 0
      counts[address.name] += 1
    end
    winner = counts.detect { |_k, v| v > 1 } && counts.max_by { |_k, v| v }[0]
    winner && building.addresses.select { |address| address.name == winner }
  end
end
