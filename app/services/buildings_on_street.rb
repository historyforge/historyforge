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
    items = Building.left_outer_joins(:addresses)
                    .includes(:addresses)
                    .where(addresses: { name: street_name, city: city })
                    .order("addresses.name, addresses.suffix, addresses.prefix, addresses.house_number")
    items = items.where(addresses: { prefix: street_prefix }) if street_prefix.present?
    items = items.where(addresses: { suffix: street_suffix }) if street_suffix.present?
    items = items.where("addresses.house_number LIKE ?", "#{street_house_number[0]}%" ) if street_house_number.present?
    items = items.to_a.unshift(Building.find(building_id)) if building_id && !items.detect { |b| b.id == building_id }
    items.map { |item| OpenStruct.new(id: item.id, name: item.street_address.gsub("\n", ", "))}
  end

end
