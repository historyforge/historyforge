# frozen_string_literal: true

module People
  # Projects authorized census rows into the observations needed for a narrative.
  class CensusNarrativeEvidence
    Snapshot = Data.define(:record, :residence, :household, :activity, :head)
    MISSING = %w[none blank unknown un un. illegible unreadable n/a na x ? -].freeze
    HEAD_RELATIONS = %w[daughter son stepdaughter stepson wife husband].freeze
    GENERIC_JOBS = %w[employer employee worker unemployed retired].freeze

    def self.call(records:, readable:)
      new(records:, readable:).call
    end

    def initialize(records:, readable:)
      @records = records
      @readable = readable
    end

    def call
      @records.group_by(&:year).sort_by(&:first).filter_map do |_year, records|
        # Multiple rows for one year can disagree. Leave those details to the source table.
        snapshot(records.first) if records.one?
      end
    end

    private

    def snapshot(record)
      street = usable_text(record.street_name) && usable_text(record.street_address)
      head, household = household_details(record)
      activity = activity_details(record)
      return unless street || household || activity

      place = usable_text(record.locality&.short_name) || usable_text(record.city)

      residence = if street
                    [usable_text(record.street_house_number) ? "at #{street}" : "on #{street}", ("in #{place}" if place)].compact.join(' ')
                  elsif place
                    "in #{place}"
                  end
      Snapshot.new(record:, residence:, household:, activity:, head:)
    end

    def household_details(record)
      return unless record.respond_to?(:relation_to_head) && record.family_id.present? && record.locality_id.present?

      relation = usable_text(record.relation_to_head)&.downcase
      return unless HEAD_RELATIONS.include?(relation)

      heads = record.fellows.select do |fellow|
        fellow.relation_to_head.to_s.strip.casecmp?('head') && same_household_context?(record, fellow)
      end
      return unless heads.one?

      head = heads.first
      return unless @readable.call(head) && head.name.present?

      [head, "listed as #{head.name}’s #{relation}"]
    end

    def same_household_context?(record, fellow)
      # The existing household lookup also matches locality, family number, and district when present.
      return false unless record.ward == fellow.ward
      return true if record.building_id.present? || record.dwelling_number.present?

      record.page_number == fellow.page_number && record.page_side == fellow.page_side
    end

    def activity_details(record)
      job = usable_text(record.occupation)
      case job&.downcase
      when 'student senior in high school', 'high school senior'
        return 'listed as a high school senior'
      when 'student', 'at school'
        return 'listed as attending school'
      end

      if job && !GENERIC_JOBS.include?(job.downcase)
        industry = usable_text(record.field_for(:industry))
        return "recorded with the occupation “#{job}”#{(" and industry “#{industry}”" if industry)}"
      end

      school = record.field_for(:attended_school)
      'recorded as attending school' if school == true || (school.is_a?(Integer) && school.positive?)
    end

    def usable_text(value)
      text = value.to_s.squish
      text if text.present? && !MISSING.include?(text.downcase)
    end
  end
end
