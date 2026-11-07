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
      return if @observations.empty?

      first = @observations.first
      latest_change = @observations.reverse_each.find { |entry| details(entry) != details(first) }
      selected = [first, latest_change || @observations.last].uniq
      sentences = if selected.size == 2 && !latest_change
                    [sentence(first, @name, years: selected.map { |entry| entry.record.year }.join(' and '))]
                  else
                    if selected.size == 2 && same_head?(first, selected.last)
                      selected[-1] = selected.last.with(household: nil, head: nil)
                    end
                    selected.each_with_index.map do |entry, i|
                      if i.zero?
                        sentence(entry, @name, opening: childhood_opening(entry.record.age))
                      else
                        sentence(entry, @pronoun)
                      end
                    end
                  end
      sources = selected.flat_map { |entry| [entry.record, entry.head].compact }.uniq
      Result.new(paragraph: sentences.join(' '), sources:)
    end

    private

    def same_head?(first, later)
      first.head&.person_id.present? && first.head.person_id == later.head&.person_id &&
        first.household == later.household && (later.residence || later.activity)
    end

    def details(entry)
      [entry.residence, entry.household, entry.activity]
    end

    def childhood_opening(age)
      "At #{CHILDHOOD_AGES.fetch(age - 1)}" if age&.between?(1, CHILDHOOD_AGES.length)
    end

    def sentence(entry, subject, years: entry.record.year, opening: nil)
      observations = [entry.household, entry.activity].compact
      facts = [("lived #{entry.residence}" if entry.residence)]
      facts << "#{subject == 'they' ? 'were' : 'was'} #{observations.to_sentence}" if observations.any?
      facts.compact!
      "#{opening || "In #{years}"}, #{subject} #{facts.to_sentence}."
    end
  end
end
