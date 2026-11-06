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

  def initialize(person, routes:)
    super(person)
    @routes = routes
  end

  def serializable_hash
    {
      id: object.id,
      name: object.name,
      canonical_url: @routes.person_url(object),
      summary:,
      census_observations:,
      source_links:,
      relationships:,
    }
  end

  def summary
    return @summary if defined?(@summary)

    @summary = People::CensusSummary.call(observations: census_observations)
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
          person_url: @routes.person_url(fellow.person_id),
          source_links: [source_link(record), source_link(fellow)],
        }
      end
    end
  end

  private

  def public_records
    @public_records ||= object.census_records.group_by(&:year).sort_by(&:first).flat_map do |year, records|
      Setting.can_view_public?(year) ? records.select(&:reviewed?).sort_by(&:id) : []
    end
  end

  def source_link(record)
    { year: record.year, record_id: record.id, url: @routes.polymorphic_url(record) }
  end
end
