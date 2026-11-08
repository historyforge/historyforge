# frozen_string_literal: true

module People
  class CensusSummary
    # Selects dated observations and groups repeated residences and occupations.
    class Continuity
      Result = Data.define(:observations, :residences, :occupations, :sources)

      def self.call(observations:)
        new(observations:).call
      end

      def initialize(observations:)
        @observations = observations
      end

      def call
        meaningful = @observations.select(&:meaningful?)
        first = meaningful.first
        return unless first

        latest_change = meaningful.reverse_each.find { |entry| details(entry) != details(first) }
        selected = [first, latest_change || meaningful.last].uniq
        residences = continuity_groups(selected) { |a, b| a.address_key && a.address_key == b.address_key }
        occupations = continuity_groups(selected) { |a, b| Occupation.equivalent?(a, b) }

        selected = without_repeated_details(selected, residences, occupations)
        shared_records = (residences + occupations).flatten.map(&:record)
        sources = (selected.flat_map { |entry| [entry.record, entry.head].compact } + shared_records).uniq.sort_by(&:year)
        Result.new(observations: selected, residences:, occupations:, sources:)
      end

      private

      def continuity_groups(selected)
        groups = @observations.each_with_object([]) do |entry, runs|
          # Contextual occupation matches need to hold across the whole run.
          if runs.last&.all? { |previous| yield previous, entry }
            runs.last << entry
          else
            runs << [entry]
          end
        end
        groups.select { |run| run.size > 1 && run.intersect?(selected) }
      end

      def without_repeated_details(selected, residences, occupations)
        first = selected.first
        selected.map.with_index do |entry, i|
          residence = entry.residence unless residences.any? { |group| group.include?(entry) }
          job_group = occupations.find { |group| group.include?(entry) }
          activity = if job_group
                       "recorded in the industry “#{entry.industry}”" if entry.industry && !Occupation.shared_industry(job_group)
                     else
                       entry.activity
                     end
          omit_head = i.positive? && (residence || activity) && same_head?(first, entry)
          entry.with(residence:, activity:, household: (entry.household unless omit_head), head: (entry.head unless omit_head))
        end
      end

      def same_head?(first, later)
        first.head&.person_id.present? && first.head.person_id == later.head&.person_id && first.household == later.household
      end

      def details(entry)
        [entry.residence, entry.household, entry.activity]
      end
    end
  end
end
