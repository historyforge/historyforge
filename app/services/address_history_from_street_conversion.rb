# frozen_string_literal: true

class AddressHistoryFromStreetConversion
  def initialize(street_conversion)
    @street_conversion = street_conversion
  end

  def perform
    matching_addresses&.each do |address|
      modern_address = matching_modern_address address.building
      modern_address.year = year
      modern_address.save
    end
  end

  private

  delegate :year,
           :from_house_number, :from_name, :from_prefix, :from_suffix, :from_city,
           :to_house_number, :to_name, :to_prefix, :to_suffix, :to_city,
           to: :@street_conversion

  def matching_addresses
    query = Address.includes(:building)
    query = query.where(house_number: from_house_number) if from_house_number.present?
    query = query.where(name: from_name) if from_name.present?
    query = query.where(prefix: from_prefix) if from_prefix.present?
    query = query.where(suffix: from_suffix) if from_suffix.present?
    query.where(city: from_city) if from_city.present?
  end

  def matching_modern_address(building)
    query = building.addresses
    query = query.where(house_number: to_house_number) if to_house_number.present?
    query = query.where(name: to_name) if to_name.present?
    query = query.where(prefix: to_prefix) if to_prefix.present?
    query = query.where(suffix: to_suffix) if to_suffix.present?
    query = query.where(city: to_city) if to_city.present?
    query.first_or_initialize
  end
end
