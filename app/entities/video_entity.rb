# frozen_string_literal: true

class VideoEntity < BaseEntity

  attribute :id, :integer
  attribute :caption, :string
  attribute :creator, :string
  attribute :data_uri, :string
  attribute :date_of_original, :string
  attribute :description, :string
  attribute :duration, :integer
  attribute :file_size, :integer
  attribute :height, :integer
  attribute :latitude, :decimal
  attribute :location, :string
  attribute :longitude, :decimal
  attribute :notes, :string
  attribute :processed_at, :datetime
  attribute :thumbnail_processed_at, :datetime
  attribute :type, :string, default: 'video'
  attribute :URL, :string
  attribute :width, :integer
  attribute :year, :integer
  attribute :properties, default: {}

  def self.build_from(video, year, include_related: true)
    return nil if video.nil?

    entity = new(
      id: video.id,
      caption: video.caption,
      creator: video.creator,
      data_uri: video.data_uri,
      date_of_original: video.date_text,
      description: video.description,
      duration: video.duration,
      file_size: video.file_size,
      height: video.height,
      latitude: video.latitude,
      location: video.location,
      longitude: video.longitude,
      notes: video.notes,
      processed_at: video.processed_at,
      thumbnail_processed_at: video.thumbnail_processed_at,
      type: 'video',
      URL: video.remote_url,
      width: video.width,
      year: year
    )

    if include_related
      census_records = get_census_records_for_media(video, year)
      return nil if census_records.empty?

      entity.properties = {
        people: video.people.filter_map { |p| PersonEntity.build_from(p, year, include_related: false) },
        census_records: census_records.filter_map { |record| CensusRecordEntity.build_from(record, year) },
        buildings: video.buildings.filter_map { |b| BuildingEntity.build_from(b, year, include_related: false) }
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
