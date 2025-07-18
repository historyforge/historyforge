# frozen_string_literal: true

class BaseEntity
  include ActiveModel::Model
  include ActiveModel::Attributes

  def to_h
    attributes.compact
  end

  protected

  def self.get_census_records_for_person(person, year)
    person.send("census#{year}_records")
  rescue NoMethodError
    []
  end

  def self.get_census_records_for_building(building, year)
    building.send("census#{year}_records")
  rescue NoMethodError
    []
  end

  def self.get_people_for_building(building, year)
    building.send("people_#{year}")
  rescue NoMethodError
    []
  end

  def self.get_parent_for_building(building)
    building.send(:parent)
  rescue NoMethodError
    nil
  end

  def self.get_census_records_for_media(media_item, year)
    media_item.people.flat_map { |p| p.send("census#{year}_records") }
  rescue NoMethodError
    []
  end

  def self.sanitize_url(url)
    return nil if url.blank?

    url.gsub('/admin/admin/', '/admin/')
  end
end
