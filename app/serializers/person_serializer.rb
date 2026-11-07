# frozen_string_literal: true

# The public Person and the census rows that provide evidence about them.
class PersonSerializer < ApplicationSerializer
  class ObservationSerializer < CensusRecordSerializer
    def serializable_attributes
      attributes = super + [:pob]
      attributes.delete(:relation_to_head) unless object.respond_to?(:relation_to_head)
      attributes
    end
  end

  def initialize(person, census_records:, census_readable:, url_options:)
    super(person)
    @census_records = census_records.sort_by { |record| [record.year, record.id] }
    @census_readable = census_readable
    @url_options = url_options
  end

  def serializable_hash
    {
      id: object.id,
      name: object.name,
      canonical_url: routes.person_url(object, **@url_options),
      summary:,
      summary_source_links:,
      census_observations:,
      source_links:,
      relationships:,
    }
  end

  def summary
    summary_result&.paragraph
  end

  def summary_source_links
    @summary_source_links ||= Array(summary_result&.sources).map do |record|
      label = record.person_id == object.id ? "#{record.year} census" : "#{record.year}: #{record.name}"
      source_link(record).merge(label:)
    end
  end

  def census_observations
    @census_observations ||= @census_records.map { |record| ObservationSerializer.new(record).serializable_hash }
  end

  def source_links
    @source_links ||= @census_records.map { |record| source_link(record) }
  end

  def relationships
    @relationships ||= @census_records.flat_map do |record|
      record.fellows.filter_map do |fellow|
        next unless fellow.person_id && fellow.person_id != object.id && @census_readable.call(fellow)

        {
          type: 'census_household_member',
          person_id: fellow.person_id,
          person_url: routes.person_url(fellow.person_id, **@url_options),
          source_links: [source_link(record), source_link(fellow)],
        }
      end
    end
  end

  private

  def routes
    Rails.application.routes.url_helpers
  end

  def summary_result
    return @summary_result if defined?(@summary_result)

    observations = People::CensusNarrativeEvidence.call(records: @census_records, readable: @census_readable)
    @summary_result = People::CensusSummary.call(name: object.name, sex: object.sex, observations:)
  end

  def source_link(record)
    { year: record.year, record_id: record.id, url: routes.polymorphic_url(record, @url_options) }
  end
end
