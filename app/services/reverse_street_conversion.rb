class ReverseStreetConversion
  attr_accessor :address, :conversion
  delegate :to_prefix, :to_name, :to_suffix, :to_city, to: :address, allow_nil: true

  def matches?(record)
    needed_matches = [record.to_prefix, record.to_name, record.to_suffix, record.to_city].select(&:present?).size
    matches = 0
    matches += 1 if record.to_prefix.present? && address.street_prefix == record.to_prefix
    matches += 1 if record.to_name.present? && address.street_name == record.to_name
    matches += 1 if record.to_suffix.present? && address.street_suffix == record.to_suffix
    matches += 1 if record.to_city.present? && address.city == record.to_city
    matches == needed_matches
  end

  def convert
    target = ConvertibleAddress.new
    target.street_prefix = convert_attribute 'prefix'
    target.street_name   = convert_attribute 'name'
    target.street_suffix = convert_attribute 'suffix'
    target.city          = convert_attribute 'city'
    target
  end

  def convert_attribute(attr)
    from = conversion.public_send("to_#{attr}")
    to   = conversion.public_send("from_#{attr}")
    if to.present?
      to == 'null' ? nil : to
    else
      from
    end
  end

  def self.convert(address_str)
    number, address = from_string address_str
    converter = ReverseStreetConversion.new
    converter.address = address
    converter.conversion = StreetConversion.all.detect { |record| converter.matches?(record) }
    if converter.conversion
      address = converter.convert
      [number, address.street_prefix, address.street_name, address.street_suffix].compact.join(' ')
    else
      address_str
    end
  end

  def self.from_string(address_str)
    address = ConvertibleAddress.new
    bits = address_str.split(' ')
    number = bits.shift if bits.first.to_i > 0
    start = bits.shift
    if start
      start = 'N' if start.downcase == 'north'
      start = 'S' if start.downcase == 'south'
      start = 'E' if start.downcase == 'east'
      start = 'W' if start.downcase == 'west'
      if start.size == 1
        address.street_prefix = start
        address.street_name = bits.shift
      else
        address.street_name = start
      end
    end
    address.street_suffix = bits.shift if bits.any?
    [number, address]
  end
end

