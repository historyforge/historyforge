# frozen_string_literal: true

module People
  class LikelyMatches < ApplicationInteraction
    include FastMemoize

    # @!attribute [r] record
    #   @return [Class<CensusRecord>]
    object :record, class: 'CensusRecord'

    # @!attribute [r] year
    #   @return [Integer]
    # @!attribute [r] age
    #   @return [Integer]
    # @!attribute [r] sex
    #   @return [String]
    delegate :year, :age, :sex, to: :record

    def execute
      return empty_result if only_one_census_going?
      
      matches = exact_matches
      return { matches:, exact: true } if matches.present?

      { matches: fuzzy_matches, exact: false }
    end

    private

    def empty_result
      { matches: [], exact: false }
    end

    def only_one_census_going?
      compose(CensusRecords::SingleCensus)
    end

    def filter_matches(matches)
      matches
        .preload(*CensusYears.map { |year| :"census#{year}_records" })
        .to_a
        .select { |match| match.similar_in_age?(year, age) }
    end

    def first_name
      @first_name ||= record.first_name.downcase
    end

    def last_name
      @last_name ||= record.last_name.downcase
    end

    def first_name_cognates
      Nicknames.matches_for(first_name, sex)
    end
    memoize :first_name_cognates

    def first_names_with_last_name
      names = first_name_cognates.map { |name| "#{name} #{last_name}" }
      return names unless record.middle_name.present?

      middle_name_cognates = Nicknames.matches_for(record.middle_name.downcase, sex)
      names + middle_name_cognates.map { |name| "#{name} #{last_name}" }
    end

    def exact_matches
      query = Person.where(sex:)
                   .where(id: person_name_subquery)
                   .order('people.first_name, people.middle_name')
      
      matches = if_exists(query)
      matches && filter_matches(matches)
    end

    def person_name_subquery
      PersonName.select(:person_id)
               .where(name_conditions)
               .where('person_names.person_id = people.id')
    end

    def name_conditions
      [
        '(lower(person_names.first_name) IN (?) OR person_names.first_name % ? OR ' \
        'person_names.middle_name IN (?) OR person_names.middle_name % ?) AND ' \
        'person_names.last_name % ?',
        first_name_cognates, first_name, first_name_cognates, first_name, last_name
      ]
    end

    def fuzzy_matches
      top_matches = filter_matches(last_name_matches) if last_name_matches
      bottom_matches = filter_matches(fuzzy_name_matches) if fuzzy_name_matches
      
      [top_matches, bottom_matches].compact.flatten
    end

    def fuzzy_name_matches
      if_exists(Person.fuzzy_name_search(first_names_with_last_name)
                      .where(sex:)
                      .limit(20))  # Increased limit to accommodate more potential matches
    end

    def last_name_matches
      if_exists(Person.where(sex:)
                  .where(id: PersonName.select(:person_id)
                               .where('LOWER(person_names.last_name) = ? OR LOWER(person_names.first_name) = ?', last_name, last_name)
                               .where('person_names.person_id=people.id'))
                      .order(:first_name, :middle_name).limit(10))
    end

    def if_exists(matches)
      matches.exists? ? matches : false
    end
  end
end
