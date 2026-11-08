# frozen_string_literal: true

# Represents a Person using the census evidence authorized by the caller.
class PersonSerializer < ApplicationSerializer
  class ObservationSerializer < CensusRecordSerializer
    def serializable_attributes
      attributes = super + [:pob]
      attributes.delete(:relation_to_head) unless object.respond_to?(:relation_to_head)
      attributes
    end
  end

  def initialize(person, census_records:, census_households:, url_options:)
    super(person)
    @census_records = census_records.sort_by { |record| [record.year, record.id] }
    @census_households = census_households
    @url_options = url_options
  end

  def serializable_hash
    {
      id:,
      name:,
      alternate_names:,
      canonical_url:,
      summary:,
      summary_source_links:,
      description:,
      birth_year:,
      death_year:,
      census_observations:,
      source_links:,
      relationships:,
    }
  end

  delegate :id, :name, to: :object

  def canonical_url
    @canonical_url ||= routes.person_url(object, **canonical_url_options)
  end

  def alternate_names
    @alternate_names ||= object.variant_names.map(&:short_name).compact_blank.uniq - [name]
  end

  def description
    summary || CGI.unescapeHTML(ActionController::Base.helpers.strip_tags(object.description).to_s).presence
  end

  def birth_year
    object.birth_year if object.is_birth_year_estimated == false
  end

  def death_year
    object.death_year if object.is_death_year_estimated == false
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
      @census_households.fetch(record).fellows.filter_map do |fellow|
        next unless fellow.person_id && fellow.person_id != object.id

        {
          type: 'census_household_member',
          person_id: fellow.person_id,
          person_url: routes.person_url(fellow.person_id, **canonical_url_options),
          source_links: [source_link(record), source_link(fellow)],
        }
      end
    end
  end

  private

  def canonical_url_options
    @canonical_url_options ||= @url_options.merge(People::PublicUrlOptions.call)
  end

  def routes
    Rails.application.routes.url_helpers
  end

  def summary_result
    return @summary_result if defined?(@summary_result)

    observations = People::CensusSummary::Evidence.call(records: @census_records, households: @census_households)
    @summary_result = People::CensusSummary.call(name: object.name, sex: object.sex, observations:)
  end

  def source_link(record)
    { year: record.year, record_id: record.id, url: routes.polymorphic_url(record, @url_options) }
  end
end
