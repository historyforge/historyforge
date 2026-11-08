# frozen_string_literal: true

module People
  class CensusSummary
    # Groups dated evidence independently for work, residence, and household.
    class Continuity
      Result = Data.define(:occupations, :residences, :households) do
        def sources
          members = households.flatten.to_h { |entry| [entry.record, entry.household.member] }
          records = (occupations + residences + households).flatten.map(&:record).uniq.sort_by(&:year)
          records.flat_map { |record| [record, members[record]].compact }.uniq
        end
      end

      def self.call(observations:)
        new(observations:).call
      end

      def initialize(observations:)
        @observations = observations.sort_by { |entry| entry.record.year }
      end

      def call
        occupations = runs(:activity) do |first, later|
          if first.occupation || later.occupation
            Occupation.equivalent?(first, later)
          else
            school_activity(first) == school_activity(later)
          end
        end
        residences = runs(:residence) { |first, later| same_residence?(first, later) }
        if residences.flatten.any? { |entry| street_residence?(entry) }
          residences = residences.select { |group| street_residence?(group.first) }
        end
        households = runs(:household) do |first, later|
          member_id = first.household.member.person_id
          member_id.present? && member_id == later.household.member.person_id &&
            first.household.role == later.household.role
        end

        return if occupations.empty? && residences.empty? && households.empty?

        explicit = households.select { |group| group.first.household.role }
        households = explicit if explicit.any?
        Result.new(occupations:, residences:, households: select_households(households))
      end

      private

      def select_households(groups)
        # Check all dated observations before shortening the account to two groups.
        conflict = groups.combination(2).find do |first, later|
          earlier = first.first.household
          newer = later.first.household
          earlier.member.person_id.present? && earlier.member.person_id == newer.member.person_id &&
            earlier.role != newer.role
        end
        return conflict if conflict

        groups.size > 2 ? [groups.first, groups.last] : groups
      end

      def school_activity(entry)
        entry.activity.delete_prefix('listed as ').delete_prefix('recorded as ')
      end

      def runs(field)
        groups = []
        current = []
        @observations.each do |entry|
          unless entry.public_send(field)
            current = []
            next
          end

          # Contextual matches must hold across the whole run.
          if current.empty? || !current.all? { |previous| yield previous, entry }
            current = []
            groups << current
          end
          current << entry
        end
        groups
      end

      def street_residence?(entry)
        entry.residence.start_with?('at ', 'on ')
      end

      def same_residence?(first, later)
        if first.address_key || later.address_key
          return first.address_key == later.address_key
        end

        # Two road-only observations can establish the same road, never the same house.
        return false if first.residence.start_with?('at ') || later.residence.start_with?('at ')

        first.record.locality_id == later.record.locality_id &&
          first.record.field_for(:state).to_s.casecmp?(later.record.field_for(:state).to_s) &&
          first.residence.casecmp?(later.residence)
      end
    end
  end
end
