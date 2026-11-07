# frozen_string_literal: true

module People
  # Builds a short account from census rows the current viewer can read.
  class CensusSummary
    Result = Data.define(:paragraph, :sources)
    Snapshot = Data.define(:record, :residence, :household, :activity, :head)
    MISSING = %w[none blank unknown un un. illegible unreadable n/a na x ? -].freeze
    HEAD_RELATIONS = %w[daughter son stepdaughter stepson wife husband].freeze
    GENERIC_JOBS = %w[employer employee worker unemployed retired].freeze

    def self.call(name:, records:, readable:)
      new(name:, records:, readable:).call
    end

    def initialize(name:, records:, readable:)
      @name = name
      @records = records
      @readable = readable
    end

    def call
      snapshots = @records.group_by(&:year).sort_by(&:first).filter_map do |_year, records|
        # Multiple rows for one year can disagree. Leave those details to the source table.
        snapshot(records.first) if records.one?
      end
      return if snapshots.empty?

      first = snapshots.first
      latest_change = snapshots.reverse_each.find { |entry| details(entry) != details(first) }
      selected = [first, latest_change || snapshots.last].uniq
      sentences = if selected.size == 2 && !latest_change
                    [sentence(first, @name, years: selected.map { |entry| entry.record.year }.join(' and '))]
                  else
                    if selected.size == 2 && same_head?(first, selected.last)
                      selected[-1] = selected.last.with(household: nil, head: nil)
                    end
                    selected.each_with_index.map { |entry, i| sentence(entry, i.zero? ? @name : 'they', later: i.positive?) }
                  end
      sources = selected.flat_map { |entry| [entry.record, entry.head].compact }.uniq
      Result.new(paragraph: sentences.join(' '), sources:)
    end

    private

    def same_head?(first, later)
      first.head&.person_id.present? && first.head.person_id == later.head&.person_id &&
        first.household == later.household && (later.residence || later.activity)
    end

    def snapshot(record)
      street = usable_text(record.street_name) && usable_text(record.street_address)
      place = usable_text(record.locality&.short_name) || usable_text(record.city)
      head, household = household_details(record)
      activity = activity_details(record)
      return unless street || household || activity

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

    def details(entry)
      [entry.residence, entry.household, entry.activity]
    end

    def sentence(entry, subject, years: entry.record.year, later: false)
      observations = [entry.household, entry.activity].compact
      facts = [("lived #{entry.residence}" if entry.residence)]
      facts << "#{later ? 'were' : 'was'} #{observations.to_sentence}" if observations.any?
      facts.compact!
      "In #{years}, #{subject} #{facts.to_sentence}."
    end

    def usable_text(value)
      text = value.to_s.squish
      text if text.present? && !MISSING.include?(text.downcase)
    end
  end
end
