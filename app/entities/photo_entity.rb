# frozen_string_literal: true

class PhotoEntity < BaseEntity

  attribute :id, :integer
  attribute :caption, :string
  attribute :content_type, :string
  attribute :creator, :string
  attribute :data_uri, :string
  attribute :date_of_original, :string
  attribute :description, :string
  attribute :latitude, :decimal
  attribute :location, :string
  attribute :longitude, :decimal
  attribute :notes, :string
  attribute :type, :string, default: 'photo'
  attribute :URL, :string
  attribute :year, :integer
  attribute :properties, default: {}

  def self.build_from(photo, year, include_related: true)
    return nil if photo.nil?

    entity = new(
      id: photo.id,
      caption: photo.caption,
      content_type: photo.file_attachment&.content_type,
      creator: photo.creator,
      data_uri: photo.data_uri,
      date_of_original: photo.date_text,
      description: photo.description,
      latitude: photo.latitude,
      location: photo.location,
      longitude: photo.longitude,
      notes: photo.notes,
      type: 'photo',
      URL: photo.file_attachment.present? ? sanitize_url(Rails.application.routes.url_helpers.rails_blob_url(photo.file_attachment, host: ENV.fetch('BASE_URL', nil))) : nil,
      year: year
    )

    if include_related
      census_records = get_census_records_for_media(photo, year)
      return nil if census_records.empty?

      entity.properties = {
        people: photo.people.filter_map { |p| PersonEntity.build_from(p, year, include_related: false) },
        census_records: census_records.filter_map { |record| CensusRecordEntity.build_from(record, year) },
        buildings: photo.buildings.filter_map { |b| BuildingEntity.build_from(b, year, include_related: false) }
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
