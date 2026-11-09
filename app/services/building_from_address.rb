# frozen_string_literal: true

class BuildingFromAddress
  def initialize(record, latitude: nil, longitude: nil)
    @record = record
    @latitude = latitude
    @longitude = longitude
  end

  attr_reader :record

  def perform
    return if record.street_house_number.blank? || record.street_name.blank?
    return unless original_address
    return original_address.building if original_address.persisted?
    return unless modern_address
    return modern_address.building if modern_address.persisted?

    building = Building.new locality: record.locality,
                            lat: @latitude,
                            lon: @longitude,
                            building_type_ids: [3] # residence

    modern_address.is_primary = true
    building.addresses << modern_address
    building.addresses << original_address unless original_address.address == modern_address.address
    raise(building.errors.inspect) unless building.save

    building
  end

  private

  def original_address
    return @original_address if defined?(@original_address)

    @original_address = find_or_build_address(record.city,
                                              house_number: record.street_house_number,
                                              prefix: record.street_prefix,
                                              name: record.street_name,
                                              suffix: record.street_suffix)
  end

  def modern_address
    return @modern_address if defined?(@modern_address)

    base = ConvertibleAddress.new(record).modernize
    @modern_address = find_or_build_address(base.city,
                                            house_number: base.house_number,
                                            name: base.street_name,
                                            prefix: base.street_prefix,
                                            suffix: base.street_suffix)
  end

  def find_or_build_address(place, **street)
    if record.locality_id
      matches = Address.joins(:building).where(buildings: { locality_id: record.locality_id }).where(street)
      if place.present?
        exact_matches = matches.where(city: place)
        matches = exact_matches if exact_matches.exists?
      end

      building_ids = matches.distinct.limit(2).pluck(:building_id)
      return if building_ids.size > 1
      return matches.first if building_ids.one?
    end

    Address.new(**street, city: place)
  end
end
