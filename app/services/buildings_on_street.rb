# frozen_string_literal: true

# Finds records of buildings on the same street. If a house number is provided, then it limits the results to
# those buildings that start with the first number of the house number.
class BuildingsOnStreet
  def initialize(record)
    @building_id = record.building_id
    @street_house_number = record.street_house_number
    @street_prefix = record.street_prefix
    @street_name = record.street_name
    @street_suffix = record.street_suffix
    @city = record.city
  end

  attr_reader :building_id, :street_house_number, :street_name, :street_prefix, :street_suffix, :city

  def perform
    buildings_on_street
  end

  Row = Struct.new(:id, :name)

  private

  def buildings_on_street
    items = Building.left_outer_joins(:addresses)
                    .includes(:addresses)
                    .where(addresses: { name: street_name, city: city })
                    .order('addresses.name, addresses.suffix, addresses.prefix, addresses.house_number')
    items = items.where(addresses: { prefix: street_prefix }) if street_prefix.present?
    items = items.where(addresses: { suffix: street_suffix }) if street_suffix.present?

    # If we have a house number then let's limit to addresses matching the first digit. When searching for "5" this
    # winnows out "405" but not "5", "50", or "5090". So it doesn't quite meet the desire of "show all buildings within
    # the hundred block".
    items = items.where('addresses.house_number LIKE ?', "#{street_house_number[0]}%") if street_house_number.present?

    # Ensures that the record's building address is at the top of the list even if it isn't returned by the query
    items = items.to_a.unshift(Building.find(building_id)) if building_id && !items.detect { |b| b.id == building_id }

    items.map { |item| Row.new item.id, item.street_address.gsub("\n", ', ') }
  end
end
