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

  def initialize(person, url_options:)
    super(person)
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
    @census_observations ||= public_records.map { |record| ObservationSerializer.new(record).serializable_hash }
  end

  def source_links
    @source_links ||= public_records.map { |record| source_link(record) }
  end

  def relationships
    @relationships ||= public_records.flat_map do |record|
      record.fellows.filter_map do |fellow|
        next unless fellow.person_id && fellow.person_id != object.id && fellow.reviewed?

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

    observations = People::CensusNarrativeEvidence.call(records: public_records, readable: :reviewed?.to_proc)
    @summary_result = People::CensusSummary.call(name: object.name, sex: object.sex, observations:)
  end

  def public_records
    @public_records ||= object.census_records.group_by(&:year).sort_by(&:first).flat_map do |year, records|
      Setting.can_view_public?(year) ? records.select(&:reviewed?).sort_by(&:id) : []
    end
  end

  def source_link(record)
    { year: record.year, record_id: record.id, url: routes.polymorphic_url(record, @url_options) }
  end
end
