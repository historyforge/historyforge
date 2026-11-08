# frozen_string_literal: true

module People
  class CensusSummary
    # Projects authorized census rows into the observations needed for a narrative.
    class Evidence
      Snapshot = Data.define(:record, :residence, :place, :road, :address_key, :household, :activity, :occupation, :industry, :head)
      MISSING = %w[none blank unknown un un. illegible unreadable n/a na x ? -].freeze
      HEAD_RELATIONS = %w[daughter son stepdaughter stepson wife husband].freeze
      GENERIC_JOBS = %w[employer employee worker unemployed retired].freeze
      STREET_SUFFIXES = {
        'avenue' => 'ave', 'boulevard' => 'blvd', 'drive' => 'dr', 'lane' => 'ln',
        'place' => 'pl', 'road' => 'rd', 'street' => 'st', 'terrace' => 'ter',
      }.freeze

      def self.call(records:, households:)
        new(records:, households:).call
      end

      def initialize(records:, households:)
        @records = records
        @households = households
        @linked_names = {}
      end

      def call
        @records.group_by(&:year).sort_by(&:first).map do |_year, records|
          # Multiple rows for one year can disagree. Leave those details to the source table.
          if records.one?
            snapshot(records.first)
          else
            empty_snapshot(records.first)
          end
        end
      end

      private

      def snapshot(record)
        street = usable_text(record.street_name) && usable_text(record.street_address)
        head, household = household_details(record)
        activity, occupation, industry = activity_details(record)
        return empty_snapshot(record) unless street || household || activity

        place = usable_text(record.locality&.short_name) || usable_text(record.city)

        residence = if street
                      [usable_text(record.street_house_number) ? "at #{street}" : "on #{street}", ("in #{place}" if place)].compact.join(' ')
                    elsif place
                      "in #{place}"
                    end
        Snapshot.new(record:, residence:, place:, road: road_label(record, street), address_key: address_key(record, street, place),
                     household:, activity:, occupation:, industry:, head:)
      end

      def empty_snapshot(record)
        Snapshot.new(record:, residence: nil, place: nil, road: nil, address_key: nil, household: nil,
                     activity: nil, occupation: nil, industry: nil, head: nil)
      end

      def road_label(record, street)
        return unless street

        number = usable_text(record.street_house_number)
        road = number ? street.delete_prefix("#{number} ") : street
        road.split(/\s+(?:apt\.?|apartment)\s+/i, 2).first
      end

      def address_key(record, street, place)
        return unless street && place && usable_text(record.street_house_number)

        # Match formatting without folding different house or apartment numbers together.
        street_part, apartment = street.downcase.tr(',', ' ').squish.split(/\s+(?:apt\.?|apartment)\s+/, 2)
        return if street_part.blank? || (apartment && !usable_text(apartment))

        tokens = street_part.split
        if tokens.size > 2
          suffix = tokens.last.delete_suffix('.')
          tokens[-1] = STREET_SUFFIXES.fetch(suffix, suffix)
        end
        locality = record.locality_id || [place.downcase, usable_text(record.field_for(:state))&.downcase]
        [locality, tokens.join(' '), apartment]
      end

      def household_details(record)
        head = @households.fetch(record).head
        return unless head

        relation = usable_text(record.relation_to_head)&.downcase
        return unless HEAD_RELATIONS.include?(relation)

        name = if head.person_id
                 @linked_names.fetch(head.person_id) { @linked_names[head.person_id] = head.person&.name.presence }
               end
        name ||= head.name.presence
        [head, "the #{relation} of #{name}"] if name
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
          activity = "recorded with the occupation “#{job}”#{(" and industry “#{industry}”" if industry)}"
          return [activity, job, industry]
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
end
