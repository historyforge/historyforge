# frozen_string_literal: true

class BuildingEntity < BaseEntity

  attribute :id, :integer
  attribute :address, :string
  attribute :architects, :string
  attribute :block_number, :string
  attribute :building_types, :string
  attribute :description_name, :string
  attribute :description, :string
  attribute :frame, :string
  attribute :historical_addresses, :string
  attribute :latitude, :decimal
  attribute :lining, :string
  attribute :locality, :string
  attribute :location, :string
  attribute :longitude, :decimal
  attribute :name, :string
  attribute :notes, :string
  attribute :photo, :string
  attribute :parent
  attribute :rich_description_name, :string
  attribute :rich_description, :string
  attribute :stories, :string
  attribute :year_earliest, :integer
  attribute :year_latest, :integer
  attribute :year_split_from_parent, :integer
  attribute :year, :integer
  attribute :properties, default: {}

  def self.build_from(building, year, include_related: true)
    return nil if building.nil?

    building = building.decorate if building.respond_to?(:decorate)
    parent = get_parent_for_building(building)

    entity = new(
      id: building.id,
      address: building.primary_street_address.gsub(/\s+/, ' ').strip,
      architects: building.architects,
      block_number: building.block_number,
      building_types: building.building_type,
      description_name: building.object.description&.name,
      description: building.object.description&.body&.to_html,
      frame: building.frame,
      historical_addresses: building.historical_addresses,
      latitude: building.latitude,
      lining: building.lining,
      locality: building.locality,
      location: building.coordinates,
      longitude: building.longitude,
      name: building.name,
      notes: building.notes,
      photo: building.photos&.first&.data_uri,
      parent: parent,
      rich_description_name: building.rich_text_description.name,
      rich_description: building.rich_text_description.body,
      stories: building.stories,
      year_earliest: building.year_earliest,
      year_latest: building.year_latest,
      year_split_from_parent: building.hive_year,
      year: year
    )

    if include_related
      census_records = get_census_records_for_building(building, year)
      people = get_people_for_building(building, year)

      # Skip if there are no census records for this year (for strict mode)
      # Note: should_skip_empty_census? method will need to be passed in or configured

      entity.properties = {
        census_records: census_records.filter_map { |record| CensusRecordEntity.build_from(record, year) },
        people: people.filter_map { |p| PersonEntity.build_from(p, year, include_related: false) },
        stories: building.narratives.filter_map { |n| NarrativeEntity.build_from(n, year, include_related: false) },
        photos: building.photos.filter_map { |p| PhotoEntity.build_from(p, year, include_related: false) },
        audios: building.audios.filter_map { |a| AudioEntity.build_from(a, year, include_related: false) },
        videos: building.videos.filter_map { |v| VideoEntity.build_from(v, year, include_related: false) },
        documents: building.documents.filter_map { |d| DocumentEntity.build_from(d, year, include_related: false) },
        addresses: building.addresses.map(&:as_json)
      }
    end

    entity
  end

  def to_h
    attributes.compact.tap do |hash|
      hash['properties'] = properties if properties.present?
    end
  end

  def coordinates
    return nil unless latitude&.nonzero? && longitude&.nonzero?

    [longitude, latitude]
  end

  def self.to_geojson(buildings)
    {
      type: 'FeatureCollection',
      features: buildings.map do |entity|
        {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: entity.coordinates
          },
          properties: {
            location_id: entity.id,
            year: entity.year,
            title: entity.name.to_s.strip,
            addresses: entity.properties[:addresses] || [],
            audios: entity.properties[:audios] || [],
            stories: entity.properties[:stories] || [],
            videos: entity.properties[:videos] || [],
            photos: entity.properties[:photos] || [],
            documents: entity.properties[:documents] || [],
            description: entity.description&.to_s&.strip,
            rich_description: entity.rich_description,
            census_records: entity.properties[:census_records] || [],
            people: entity.properties[:people] || []
          }
        }
      end
    }
  end

end
