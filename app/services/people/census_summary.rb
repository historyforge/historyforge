# frozen_string_literal: true

module People
  # Builds a summary from census records the caller has already authorized.
  class CensusSummary
    Result = Data.define(:paragraph, :sources)
    UNKNOWN_PLACES = ['unknown', 'un', 'un.', 'illegible', '?', 'n/a'].freeze

    def self.call(records:)
      new(records:).call
    end

    def initialize(records:)
      @records = records.sort_by { |record| [record.year, record.id] }
    end

    def call
      return if @records.empty?

      years = @records.map(&:year).uniq
      appearance = if years.one?
                     "This person is listed in the #{years.first} census."
                   else
                     "This person is listed in the #{years.to_sentence} censuses."
                   end

      Result.new(paragraph: [appearance, birth_year_sentence, birthplace_sentence].compact.join(' '),
                 sources: @records)
    end

    private

    def birth_year_sentence
      estimates = @records.filter_map do |record|
        record.year - record.age if record.age&.between?(0, 120)
      end
      return if estimates.empty?

      earliest, latest = estimates.minmax
      # Census ages in completed years can put the birth on either side of New Year.
      return 'The recorded ages suggest conflicting birth years.' if latest - earliest > 1

      "The recorded #{estimates.one? ? 'age suggests' : 'ages suggest'} a birth year around #{earliest}."
    end

    def birthplace_sentence
      places = @records.filter_map do |record|
        place = record.pob.to_s.squish
        place if place.present? && UNKNOWN_PLACES.exclude?(place.downcase)
      end.uniq(&:downcase)
      return if places.empty?
      return 'The census records list different birthplaces.' if places.many?

      "The recorded birthplace is #{places.first}."
    end
  end
end
