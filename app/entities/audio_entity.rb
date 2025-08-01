# frozen_string_literal: true

class AudioEntity < BaseEntity

  attribute :id, :integer
  attribute :caption, :string
  attribute :creator, :string
  attribute :data_uri, :string
  attribute :date_of_original, :string
  attribute :description, :string
  attribute :duration, :integer
  attribute :file_size, :integer
  attribute :identifier, :string
  attribute :latitude, :decimal
  attribute :location, :string
  attribute :longitude, :decimal
  attribute :notes, :string
  attribute :processed_at, :datetime
  attribute :type, :string, default: 'audio'
  attribute :URL, :string
  attribute :year, :integer
  attribute :properties, default: {}

  def self.build_from(audio, year, include_related: true)
    return nil if audio.nil?

    entity = new(
      id: audio.id,
      caption: audio.caption,
      creator: audio.creator,
      data_uri: audio.data_uri,
      date_of_original: audio.date_text,
      description: audio.description,
      duration: audio.duration,
      file_size: audio.file_size,
      identifier: audio.identifier,
      latitude: audio.latitude,
      location: audio.location,
      longitude: audio.longitude,
      notes: audio.notes,
      processed_at: audio.processed_at,
      type: 'audio',
      URL: audio.remote_url,
      year: year
    )

    if include_related
      census_records = get_census_records_for_media(audio, year)
      return nil if census_records.empty?

      entity.properties = {
        people: audio.people.filter_map { |p| PersonEntity.build_from(p, year, include_related: false) },
        census_records: census_records.filter_map { |record| CensusRecordEntity.build_from(record, year) },
        buildings: audio.buildings.filter_map { |b| BuildingEntity.build_from(b, year, include_related: false) }
      }
    end

    entity
  end

  def to_h
    attributes.compact.tap do |hash|
      hash['properties'] = properties if properties.present?
    end
  end

  private

end
