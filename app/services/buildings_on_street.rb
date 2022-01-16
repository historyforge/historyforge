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

  HOUSE_SQL = "substring(house_number, '^[0-9]+')::int"

  def buildings_on_street
    items = Building.left_outer_joins(:addresses)
                    .includes(:addresses)
                    .where(addresses: { name: street_name })
                    .order(Arel.sql("addresses.name, addresses.suffix, addresses.prefix, #{HOUSE_SQL}"))
    items = items.where(addresses: { city: city }) if city.present?
    items = items.where(addresses: { prefix: street_prefix }) if street_prefix.present?
    items = items.where(addresses: { suffix: street_suffix }) if street_suffix.present?
    items = add_block_filter(items) if street_house_number.present?
    items = items.to_a.unshift(Building.find(building_id)) if building_id && !items.detect { |b| b.id == building_id }

    items.to_a.uniq.map { |item| Row.new item.id, item.street_address_for_building_id }
  end

  def add_block_filter(items)
    base_number = street_house_number.to_i
    base_number += 1 if (base_number % 10).zero?
    sql = if base_number < 100
            "#{HOUSE_SQL} < 100"
          elsif base_number < 1_000
            hundred_block = (base_number.to_d / 1_000.to_d) * 10
            "#{HOUSE_SQL} BETWEEN #{hundred_block.floor}00 AND (#{hundred_block.ceil}00 - 1)"
          elsif base_number < 10_000
            hundred_block = (base_number.to_d / 10_000.to_d) * 100
            "#{HOUSE_SQL} BETWEEN #{hundred_block.floor}00 AND (#{hundred_block.ceil}00 - 1)"
          else
            hundred_block = (base_number.to_d / 100_000.to_d) * 1000
            "#{HOUSE_SQL} BETWEEN #{hundred_block.floor}00 AND (#{hundred_block.ceil}00 - 1)"
          end

    items.where Arel.sql(sql)
  end
end
