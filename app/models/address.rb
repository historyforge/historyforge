class Address < ApplicationRecord
  include AutoStripAttributes

  belongs_to :building

  auto_strip_attributes :city, :house_number, :name, :prefix, :suffix
  validates :year_earliest, :year_latest, numericality: { minimum: 1500, maximum: 2100, allow_nil: true }

  ransacker :street_address, formatter: proc { |v| v.mb_chars.downcase.to_s } do |parent|
    Arel::Nodes::NamedFunction.new('LOWER',
                                   [Arel::Nodes::NamedFunction.new('concat_ws',
                                                                   [Arel::Nodes::Quoted.new(' '),
                                                                    parent.table[:house_number],
                                                                    parent.table[:prefix],
                                                                    parent.table[:name],
                                                                    parent.table[:suffix],
                                                                    parent.table[:year_earliest],
                                                                    parent.table[:year_latest]
                                                                   ])])
  end

  def address
    [house_number, prefix, name, suffix].join(' ') + ((!year_earliest.nil? || !year_latest.nil?) ?
      ' (' + (year_earliest.nil? ? '' : year_earliest.to_s) + (!year_earliest.nil? && !year_latest.nil? ? '-' : '') + (!year_latest.nil? ? year_latest.to_s : '') + ')' : '')
  end

  def equals?(address)
    house_number == address.house_number && prefix == address.prefix && name == address.name && suffix == address.suffix
  end

  def self.from(item)
    if item.kind_of?(Building)
      item.addresses.find_or_create_by(
        house_number: item.read_attribute(:address_house_number),
        prefix:       item.read_attribute(:address_street_prefix),
        name:         item.read_attribute(:address_street_name),
        suffix:       item.read_attribute(:address_street_suffix),
        city:         item.read_attribute(:city),
        year_earliest: item.read_attribute(:address_year_earliest),
        year_latest:  item.read_attribute(:address_year_latest),
        # postal_code:  item.postal_code,
        is_primary:   true
      )
    elsif item.kind_of?(CensusRecord)
      return if item.building_id.blank?

      item.building.addresses.find_or_create_by(
        house_number: item.read_attribute(:street_house_number),
        prefix:       item.read_attribute(:street_prefix),
        name:         item.read_attribute(:street_name),
        suffix:       item.read_attribute(:street_suffix),
        city:         item.read_attribute(:city),
        year_earliest: item.read_attribute(:year_earliest),
        year_latest:  item.read_attribute(:year_latest),
        # postal_code:  item.postal_code,
      )
    end
  end
end
