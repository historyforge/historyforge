# frozen_string_literal: true

# Finds records of buildings on the same street. If a house number is provided, then it limits the results to
# those buildings that start with the first number of the house number.
module Buildings
  class PossibleMatches
    def initialize(record)
      if record.is_a?(Building)
        initialize_from_building(record)
      else
        initialize_from_census_record(record)
      end
    end

    attr_reader :building_id, :street_house_number, :street_name, :street_prefix, :street_suffix, :locality_id, :year, :is_building

    def self.perform(record)
      new(record).buildings_on_street
    end

    def buildings_on_street
      items = Building.where(locality_id:)
                      .left_outer_joins(:addresses)
                      .includes(:addresses)
                      .where(addresses: { name: street_name })
      items = items.where.not(id: building_id) if is_building
      items = items.where(addresses: { prefix: street_prefix }) if street_prefix.present?
      items = items.where(addresses: { suffix: street_suffix }) if street_suffix.present?
      items = add_block_filter(items) if street_house_number.present?
      if !is_building && building_id && !items.detect { |b| b.id == building_id }
        items = items.to_a.unshift(Building.find(building_id))
      end
      items
        .to_a
        .uniq
        .map { |item| Row.new item.id, item.street_address_for_building_id(year) }
        .sort_by { |row| row.name.to_i }
    end

    private

    def initialize_from_census_record(record)
      @building_id = record.building_id
      @street_house_number = record.street_house_number
      @street_prefix = record.street_prefix
      @street_name = record.street_name
      @street_suffix = record.street_suffix
      @locality_id = record.locality_id
      @year = record.year
    end

    def initialize_from_building(record)
      @is_building = true
      @building_id = record.id
      address = record.address
      return if address.blank?

      @street_house_number = address.house_number
      @street_prefix = address.prefix
      @street_name = address.name
      @street_suffix = address.suffix
      @locality_id = record.locality_id
      @year = record.year_earliest || 1910
    end

    Row = Struct.new(:id, :name)

    HOUSE_SQL = "substring(addresses.house_number, '^[0-9]+')::int"

    def add_block_filter(items)
      base_number = street_house_number.to_i
      base_number += 1 if (base_number % 10).zero?

      if base_number < 100
        items.where("#{HOUSE_SQL} < ?", 100)
      elsif base_number < 1_000
        hundred_block = (base_number.to_d / 1_000.to_d) * 10
        lower_bound = hundred_block.floor * 100
        upper_bound = (hundred_block.ceil * 100) - 1
        items.where("#{HOUSE_SQL} BETWEEN ? AND ?", lower_bound, upper_bound)
      elsif base_number < 10_000
        hundred_block = (base_number.to_d / 10_000.to_d) * 100
        lower_bound = hundred_block.floor * 100
        upper_bound = (hundred_block.ceil * 100) - 1
        items.where("#{HOUSE_SQL} BETWEEN ? AND ?", lower_bound, upper_bound)
      else
        hundred_block = (base_number.to_d / 100_000.to_d) * 1000
        lower_bound = hundred_block.floor * 100
        upper_bound = (hundred_block.ceil * 100) - 1
        items.where("#{HOUSE_SQL} BETWEEN ? AND ?", lower_bound, upper_bound)
      end
    end
  end
end
