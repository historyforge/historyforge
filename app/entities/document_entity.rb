# frozen_string_literal: true

class DocumentEntity < BaseEntity

  attribute :id, :integer
  attribute :available_to_public, :boolean
  attribute :category, :string
  attribute :content_type, :string
  attribute :data_uri, :string
  attribute :description, :string
  attribute :name, :string
  attribute :position, :integer
  attribute :searchable_text, :string
  attribute :URL, :string
  attribute :url, :string
  attribute :year, :integer
  attribute :properties, default: {}

  def self.build_from(document, year, include_related: true)
    return nil if document.nil?

    entity = new(
      id: document.id,
      available_to_public: document.available_to_public,
      category: document.document_category&.name,
      content_type: document.file_attachment&.blob&.content_type,
      data_uri: document.data_uri,
      description: document.description,
      name: document.name,
      position: document.position,
      searchable_text: document.respond_to?(:searchable_text) ? document.searchable_text : nil,
      URL: document.file_attachment&.blob.present? ? sanitize_url(Rails.application.routes.url_helpers.rails_blob_url(document.file_attachment, host: ENV.fetch('BASE_URL', nil))) : nil,
      url: document.url,
      year: year
    )

    if include_related
      census_record_names = ['census record', 'census', 'census records', 'census_records', 'census_record']
      is_census_document = census_record_names.include?(document.document_category&.name&.downcase)

      if is_census_document
        census_records = get_census_records_for_media(document, year)
        return nil if census_records.empty?
      end

      entity.properties = {
        people: document.people.filter_map { |p| PersonEntity.build_from(p, year, include_related: false) },
        census_records: is_census_document ? get_census_records_for_media(document, year).filter_map { |record| CensusRecordEntity.build_from(record, year) } : [],
        buildings: document.buildings.filter_map { |b| BuildingEntity.build_from(b, year, include_related: false) }
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
