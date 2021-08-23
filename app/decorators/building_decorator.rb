# frozen_string_literal: true

class BuildingDecorator < ApplicationDecorator
  def building_type
    object.building_types.map(&:name).map(&:capitalize).join('/') || 'Unknown'
  end

  alias_method :type, :building_type

  def locality
    object.locality&.name || 'None'
  end

  def street_address
    object.primary_street_address
  end

  def year_earliest
    return object.year_earliest if object.year_earliest.present?

    object.year_earliest_circa.present? ? "ca. #{object.year_earliest_circa}" : ''
  end

  def year_latest
    return object.year_latest if object.year_latest.present?

    object.year_latest_circa.present? ? "ca. #{object.year_latest_circa}" : ''
  end

  def name
    object.proper_name? ? object.name : object.street_address
  end

  def architects
    object.architects&.map(&:name)&.join(', ')
  end

  def photo
    object.photos&.first&.id
  end

  def lining
    object.lining_type&.name&.capitalize
  end

  def frame
    object.frame_type&.name&.capitalize
  end

  def stories
    return nil if object.stories.blank?

    (object.stories % 1).zero? ? object.stories.to_i : object.stories
  end

  def census_records
    return if object.residents.blank?

    object
      .residents
      .group_by(&:year)
      .each_with_object({}) { |data, hash|
        hash[data[0]] = data[1].map { |item| CensusRecordSerializer.new(item).as_json }
      }
  end
end
