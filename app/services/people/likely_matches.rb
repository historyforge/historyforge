# frozen_string_literal: true

module People
  class LikelyMatches < ApplicationInteraction
    include FastMemoize
    object :record, class: 'CensusRecord'

    def execute
      return [] if only_one_census_going?

      exact_matches || fuzzy_matches || []
    end

    private

    def only_one_census_going?
      compose(CensusRecords::SingleCensus)
    end

    def format_matches(matches)
      matches
        .limit(10)
        .preload(*CensusYears.map { |year| :"census#{year}_records" })
        .to_a
        .select { |match| match.census_records.blank? || match.similar_in_age?(record) }
    end

    def first_name
      @first_name ||= record.first_name.downcase
    end

    def last_name
      @last_name ||= record.last_name.downcase
    end

    def first_name_cognates
      Nicknames.matches_for(first_name, record.sex)
    end
    memoize :first_name_cognates

    def first_names_with_last_name
      first_name_cognates.map { |first_name| "#{first_name} #{last_name}" }
    end

    def exact_matches
      cognates = Nicknames.matches_for(first_name, record.sex)
      query = Person.where(sex: record.sex)
                    .where(id: PersonName.select(:person_id)
                                         .where('lower(person_names.first_name) in (?)', cognates)
                                         .where('person_names.last_name % ?', last_name)
                                         .where('person_names.person_id=people.id'))
                    .order('people.first_name, people.middle_name')
      matches = if_exists(query)
      matches && format_matches(matches)
    end

    def fuzzy_matches
      top_shelf = last_name_matches
      bottom_shelf = fuzzy_name_matches
      (top_shelf ? format_matches(top_shelf) : []) + (bottom_shelf ? format_matches(bottom_shelf) : [])
    end

    def fuzzy_name_matches
      if_exists(Person.fuzzy_name_search(first_names_with_last_name)
                      .where(sex: record.sex))
    end

    def last_name_matches
      if_exists(Person.where(sex: record.sex)
                  .where(id: PersonName.select(:person_id)
                               .where('LOWER(person_names.last_name) = ? OR LOWER(person_names.first_name) = ?', last_name, last_name)
                               .where('person_names.person_id=people.id'))
                      .order(:first_name, :middle_name))
    end

    def if_exists(matches)
      matches.exists? ? matches.limit(10) : false
    end
  end
end
