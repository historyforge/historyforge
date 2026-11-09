# frozen_string_literal: true

module People
  class CensusSummary
    # Projects authorized census rows into the observations needed for a narrative.
    class Evidence
      Snapshot = Data.define(:record, :residence, :place, :road, :address_key, :household, :activity, :occupation, :industry)
      Relationship = Data.define(:member, :name, :role, :kin)
      MISSING = %w[none blank unknown un un. illegible unreadable n/a na x ? -].freeze
      FAMILY_ROLES = %w[wife husband spouse mother father parent daughter son child sister brother sibling
                        stepdaughter stepson stepmother stepfather].freeze
      RECIPROCAL_ROLES = {
        'wife' => 'spouse', 'husband' => 'spouse', 'spouse' => 'spouse',
        'daughter' => 'parent', 'son' => 'parent', 'child' => 'parent',
        'mother' => 'child', 'father' => 'child', 'parent' => 'child',
        'sister' => 'sibling', 'brother' => 'sibling', 'sibling' => 'sibling',
        'stepdaughter' => 'stepparent', 'stepson' => 'stepparent',
        'stepmother' => 'stepchild', 'stepfather' => 'stepchild',
      }.freeze
      GENDERED_KIN = {
        'parent' => { 'M' => 'father', 'F' => 'mother' },
        'child' => { 'M' => 'son', 'F' => 'daughter' },
        'spouse' => { 'M' => 'husband', 'F' => 'wife' },
        'sibling' => { 'M' => 'brother', 'F' => 'sister' },
      }.freeze
      ROLE_PRIORITY = %w[spouse parent stepparent child stepchild sibling].freeze
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
        household = household_details(record)
        activity, occupation, industry = activity_details(record)
        locality = usable_text(record.locality&.short_name)
        return empty_snapshot(record) unless street || household || activity || locality

        place = locality || usable_text(record.city)

        residence = if street
                      [usable_text(record.street_house_number) ? "at #{street}" : "on #{street}", ("in #{place}" if place)].compact.join(' ')
                    elsif place
                      "in #{place}"
                    end
        Snapshot.new(record:, residence:, place:, road: road_label(record, street), address_key: address_key(record, street, place),
                     household:, activity:, occupation:, industry:)
      end

      def empty_snapshot(record)
        Snapshot.new(record:, residence: nil, place: nil, road: nil, address_key: nil, household: nil,
                     activity: nil, occupation: nil, industry: nil)
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
        household = @households.fetch(record)
        relation = family_role(record)
        if relation == 'head'
          # The fellow's census row states the relationship to this head.
          return household.members.filter_map do |member|
            kin = family_role(member)
            role = RECIPROCAL_ROLES[kin]
            relationship(record, member, role, kin:) if role
          end.min_by { |entry| ROLE_PRIORITY.index(entry.role) } || sole_household_member(record, household)
        end

        if household.head
          role = relation if FAMILY_ROLES.include?(relation)
          head = household.head
          reciprocal = RECIPROCAL_ROLES[role]
          sexes = [head.try(:sex), head.person&.try(:sex)].compact_blank.uniq if head.person_id
          sex = sexes.first if sexes&.one?
          kin = GENDERED_KIN.fetch(reciprocal, {}).fetch(sex, reciprocal)
          relationship(record, head, role, kin:)
        else
          sole_household_member(record, household)
        end
      end

      def sole_household_member(record, household)
        relationship(record, household.members.first, nil) if household.members.one?
      end

      def family_role(record)
        usable_text(record.try(:relation_to_head))&.downcase
      end

      def relationship(record, member, role, kin: nil)
        return if record.person_id && record.person_id == member.person_id

        name = usable_text(member.person&.name) if member.person_id
        name ||= usable_text(member.name)
        Relationship.new(member:, name:, role:, kin:) if name
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
