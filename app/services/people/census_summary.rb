# frozen_string_literal: true

module People
  # Builds a short account from authorized narrative evidence.
  class CensusSummary
    Result = Data.define(:paragraph, :sources)
    PRONOUNS = { 'F' => 'she', 'M' => 'he' }.freeze
    CHILDHOOD_AGES = %w[one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen].freeze
    MEDICAL_INDUSTRIES = ['clinic', 'hospital', 'medical practice', 'medicine', 'physician’s office', "physician's office"].freeze

    def self.call(name:, sex:, observations:)
      new(name:, sex:, observations:).call
    end

    def initialize(name:, sex:, observations:)
      @name = name
      @pronoun = PRONOUNS.fetch(sex, 'they')
      @observations = observations
    end

    def call
      meaningful = @observations.select(&:meaningful?)
      first = meaningful.first
      return unless first

      latest_change = meaningful.reverse_each.find { |entry| details(entry) != details(first) }
      selected = [first, latest_change || meaningful.last].uniq
      residences = continuity_groups(selected) { |a, b| a.address_key && a.address_key == b.address_key }
      occupations = continuity_groups(selected) { |a, b| same_occupation?(a, b) }

      sentences = shared_sentences(residences, occupations)
      selected = without_repeated_details(selected, residences, occupations)
      selected.select(&:meaningful?).each do |entry|
        opening = sentences.empty? && entry.record == first.record ? childhood_opening(entry.record.age) : nil
        sentences << sentence(entry, sentences.empty? ? @name : @pronoun, opening:)
      end

      shared_records = (residences + occupations).flatten.map(&:record)
      sources = (selected.flat_map { |entry| [entry.record, entry.head].compact } + shared_records).uniq.sort_by(&:year)
      Result.new(paragraph: sentences.join(' '), sources:)
    end

    private

    def continuity_groups(selected)
      groups = @observations.each_with_object([]) do |entry, runs|
        if runs.last&.all? { |previous| yield previous, entry }
          runs.last << entry
        else
          runs << [entry]
        end
      end
      groups.select { |run| run.size > 1 && run.intersect?(selected) }
    end

    def same_occupation?(first, later)
      a, b = [first.occupation, later.occupation].map { |job| job&.downcase }
      return false unless a && b
      return true if a == b
      return false unless [a, b].sort == %w[doctor physician]

      industry = first.industry&.downcase
      MEDICAL_INDUSTRIES.include?(industry) && industry == later.industry&.downcase
    end

    def common_industry(group)
      industry = group.first.industry
      industry if industry && group.all? { |entry| industry.casecmp?(entry.industry.to_s) }
    end

    def shared_sentences(residences, occupations)
      claims = residences.map do |group|
        ["recorded #{group.first.residence}", group]
      end
      occupations.each do |group|
        physician = group.find { |entry| entry.occupation.casecmp?('physician') }
        job = physician&.occupation || group.first.occupation
        industry = common_industry(group)
        claims << ["recorded with the occupation “#{job}”#{(" and industry “#{industry}”" if industry)}", group]
      end

      claims.map.with_index do |(claim, group), i|
        subject = i.zero? ? @name : @pronoun.capitalize
        years = group.map { |entry| entry.record.year }.to_sentence
        "#{subject} #{recorded_verb(subject)} #{claim} in #{'both ' if group.size == 2}#{years}."
      end
    end

    def without_repeated_details(selected, residences, occupations)
      first = selected.first
      selected.map.with_index do |entry, i|
        residence = entry.residence unless residences.any? { |group| group.include?(entry) }
        job_group = occupations.find { |group| group.include?(entry) }
        activity = if job_group
                     "recorded in the industry “#{entry.industry}”" if entry.industry && !common_industry(job_group)
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

    def childhood_opening(age)
      "At #{CHILDHOOD_AGES.fetch(age - 1)}" if age&.between?(1, CHILDHOOD_AGES.length)
    end

    def sentence(entry, subject, opening: nil)
      observations = [entry.household, entry.activity].compact
      facts = [("lived #{entry.residence}" if entry.residence)]
      facts << "#{recorded_verb(subject)} #{observations.to_sentence}" if observations.any?
      facts.compact!
      "#{opening || "In #{entry.record.year}"}, #{subject} #{facts.to_sentence}."
    end

    def recorded_verb(subject)
      subject.casecmp?('they') ? 'were' : 'was'
    end
  end
end
