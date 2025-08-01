# frozen_string_literal: true

class AddressEntity < BaseEntity

  attribute :id, :integer
  attribute :is_primary, :boolean
  attribute :name, :string
  attribute :searchable_text, :string
  attribute :prefix, :string
  attribute :street_house_number, :string
  attribute :street_name, :string
  attribute :suffix, :string
  attribute :city, :string
  attribute :state, :string
  attribute :zip, :string
  attribute :year, :integer

  def self.build_from(address, year)
    return nil if address.nil?

    address = address.decorate if address.respond_to?(:decorate)

    new(
      id: address.id,
      is_primary: address.is_primary,
      name: address.name,
      searchable_text: address.searchable_text.gsub(/\s+/, ' ').strip,
      prefix: address.prefix,
      street_house_number: address.street_house_number,
      street_name: address.street_name,
      suffix: address.suffix,
      city: address.city,
      state: address.state,
      zip: address.zip,
      year: year
    )
  end

  def to_h
    attributes.compact
  end
end
