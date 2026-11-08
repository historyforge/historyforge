# frozen_string_literal: true

module People
  # Builds a short account from authorized narrative evidence.
  class CensusSummary
    Result = Data.define(:paragraph, :sources)
    PRONOUNS = { 'F' => 'she', 'M' => 'he' }.freeze
    CHILDHOOD_AGES = %w[one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen].freeze

    def self.call(name:, sex:, observations:)
      new(name:, sex:, observations:).call
    end

    def initialize(name:, sex:, observations:)
      @name = name
      @pronoun = PRONOUNS.fetch(sex, 'they')
      @observations = observations
    end

    def call
      continuity = Continuity.call(observations: @observations)
      return unless continuity

      sentences = shared_sentences(continuity.residences, continuity.occupations)
      continuity.observations.each_with_index do |entry, i|
        next unless entry.meaningful?

        opening = sentences.empty? && i.zero? ? childhood_opening(entry.record.age) : nil
        sentences << sentence(entry, sentences.empty? ? @name : @pronoun, opening:)
      end

      Result.new(paragraph: sentences.join(' '), sources: continuity.sources)
    end

    private

    def shared_sentences(residences, occupations)
      claims = residences.map do |group|
        ["recorded #{group.first.residence}", group]
      end
      occupations.each do |group|
        job = Occupation.label(group)
        industry = Occupation.shared_industry(group)
        claims << ["recorded with the occupation “#{job}”#{(" and industry “#{industry}”" if industry)}", group]
      end

      claims.map.with_index do |(claim, group), i|
        subject = i.zero? ? @name : @pronoun.capitalize
        years = group.map { |entry| entry.record.year }.to_sentence
        "#{subject} #{recorded_verb(subject)} #{claim} in #{'both ' if group.size == 2}#{years}."
      end
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
