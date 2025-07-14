# frozen_string_literal: true

class NarrativeEntity < BaseEntity

  attribute :id, :integer
  attribute :date_of_original, :string
  attribute :notes, :string
  attribute :source_name, :string
  attribute :source, :string
  attribute :story_name, :string
  attribute :story, :string
  attribute :type, :string, default: 'story'
  attribute :weight, :integer
  attribute :year, :integer
  attribute :properties, default: {}

  def self.build_from(narrative, year, include_related: true)
    return nil if narrative.nil?

    entity = new(
      id: narrative.id,
      date_of_original: narrative.date_text,
      notes: narrative.notes,
      source_name: narrative.sources.name,
      source: narrative.sources.body,
      story_name: narrative.story.name,
      story: narrative.story.body,
      type: 'story',
      weight: narrative.weight,
      year: year
    )

    if include_related
      census_records = get_census_records_for_media(narrative, year)
      return nil if census_records.empty?

      entity.properties = {
        people: narrative.people.filter_map { |p| PersonEntity.build_from(p, year, include_related: false) },
        census_records: census_records.filter_map { |record| CensusRecordEntity.build_from(record, year) },
        buildings: narrative.buildings.filter_map { |b| BuildingEntity.build_from(b, year, include_related: false) }
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
