# frozen_string_literal: true

module People
  # Builds prose from the public census observations in a Person representation.
  class CensusSummary
    UNKNOWN_PLACES = ['unknown', 'un', 'un.', 'illegible', '?', 'n/a'].freeze

    def self.call(observations:)
      new(observations:).call
    end

    def initialize(observations:)
      @observations = observations.sort_by { |observation| observation.values_at(:year, :id) }
    end

    def call
      return if @observations.empty?

      years = @observations.pluck(:year).uniq
      appearance = if years.one?
                     "This person is listed in the #{years.first} census."
                   else
                     "This person is listed in the #{years.to_sentence} censuses."
                   end

      [appearance, birth_year_sentence, birthplace_sentence].compact.join(' ')
    end

    private

    def birth_year_sentence
      estimates = @observations.filter_map do |observation|
        year, age = observation.values_at(:year, :age)
        year - age if age&.between?(0, 120)
      end
      return if estimates.empty?

      earliest, latest = estimates.minmax
      # Census ages in completed years can put the birth on either side of New Year.
      return 'The recorded ages suggest conflicting birth years.' if latest - earliest > 1

      "The recorded #{estimates.one? ? 'age suggests' : 'ages suggest'} a birth year around #{earliest}."
    end

    def birthplace_sentence
      places = @observations.filter_map do |observation|
        place = observation[:pob].to_s.squish
        place if place.present? && UNKNOWN_PLACES.exclude?(place.downcase)
      end.uniq(&:downcase)
      return if places.empty?
      return 'The census records list different birthplaces.' if places.many?

      "The recorded birthplace is #{places.first}."
    end
  end
end
