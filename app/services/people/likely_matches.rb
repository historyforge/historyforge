# frozen_string_literal: true

module People
  class LikelyMatches < ApplicationInteraction
    include FastMemoize
    object :record, class: 'CensusRecord'
    
    def execute
      matches = exact_name_matches || fuzzy_name_matches || last_name_matches
      return [] unless matches

      CensusYears.each do |year|
        matches = matches.includes(:"census#{year}_records")
      end
      matches.select { |match| match.census_records.blank? || match.similar_in_age?(record) }
    end

    def first_name_cognates
      Nicknames.matches_for(record.first_name, record.sex)
    end
    memoize :first_name_cognates

    def first_names_with_last_name
      first_name_cognates.map { |first_name| "#{first_name} #{record.last_name}" }
    end

    private

    def last_name_matches
      matches = Person.where(sex: record.sex, last_name: record.last_name)
                      .order(:first_name, :middle_name)
      matches.exists? ? matches : false
    end

    def fuzzy_name_matches
      matches = Person.fuzzy_name_search(first_names_with_last_name)
                      .where(sex: record.sex)
      matches.exists? ? matches : false
    end

    def exact_name_matches
      matches = Person.where(sex: record.sex, last_name: record.last_name, first_name: first_name_cognates)
                      .order(:first_name, :middle_name)
      matches.exists? ? matches : false
    end
  end
end