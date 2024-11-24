# frozen_string_literal: true

class BuildingDecorator < ApplicationDecorator
  def building_type
    object.building_types.map(&:name).map(&:capitalize).join('/') || 'Unknown'
  end

  alias type building_type

  def description = object.description&.body

  def locality = object.locality&.name || 'None'

  def addresses = @addresses ||= object.addresses.sort

  def historical_addresses
    object.addresses.reject(&:is_primary).map(&:address).join(', ')
  end

  def street_address = object.primary_street_address

  def address_house_number = object.address.house_number

  def address_prefix = object.address.prefix

  def address_street_name = object.address.name

  def address_suffix = object.address.suffix

  def year_earliest = year_phrase(object.year_earliest, object.year_earliest_circa)

  def year_latest = year_phrase(object.year_latest, object.year_latest_circa)

  def year_phrase(year, circa)
    return (circa ? 'Unknown' : '') if year.blank?
    return "#{year} (ca.)" if circa

    year
  end

  def name = object.proper_name? ? object.name : object.street_address

  def architects = object.architects&.map(&:name)&.join(', ')

  def photo = object.photos&.first&.id

  def lining = object.lining_type&.name&.capitalize

  def frame = object.frame_type&.name&.capitalize

  def stories
    return nil if object.stories.blank?

    (object.stories % 1).zero? ? object.stories.to_i : object.stories
  end

  def census_records
    return if object.residents.blank?

    object
      .residents
      .group_by(&:year)
      .each_with_object({}) do |data, hash|
        hash[data[0]] = data[1].group_by(&:family_id).each_with_object([]) do |family, arr|
          arr << family[1].map { |item| CensusRecordSerializer.new(item.decorate).as_json }
        end
      end
  end
end
