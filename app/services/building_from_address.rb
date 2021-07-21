class BuildingFromAddress
  def initialize(record)
    @record = record
  end

  attr_reader :record

  def perform
    return if record.street_house_number.blank? || record.street_name.blank?
    return original_address.building if original_address.persisted?
    return modern_address.building if modern_address.persisted?

    building = Building.new name: modern_address.address,
                            city: record.city,
                            state: record.state,
                            postal_code: AppConfig.postal_code,
                            building_types: [BuildingType.find_by(name: 'residence')]

    modern_address.is_primary = true
    building.addresses << modern_address
    building.addresses << original_address unless original_address.address == modern_address.address
    raise(building.errors.inspect) unless building.save
    building
  end

  private

  def original_address
    return @original_address if defined?(@original_address)

    @original_address = Address.find_or_initialize_by house_number: record.street_house_number,
                                                      prefix: record.street_prefix,
                                                      name: record.street_name,
                                                      suffix: record.street_suffix,
                                                      city: record.city
  end

  def modern_address
    return @modern_address if defined?(@modern_address)

    base = ConvertibleAddress.new(record).modernize
    @modern_address = Address.find_or_initialize_by house_number: base.house_number,
                                                    name: base.street_name,
                                                    prefix: base.street_prefix,
                                                    suffix: base.street_suffix,
                                                    city: base.city
  end
end
