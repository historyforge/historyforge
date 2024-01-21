# frozen_string_literal: true

module People
  class LikelyMatches < ApplicationInteraction
    include FastMemoize
    object :record, class: 'CensusRecord'

    def execute
      # puts "Exact Matches: #{exact_name_matches.inspect}"
      # puts "Fuzzy Matches: #{fuzzy_name_matches.inspect}"
      # puts "Last Name Matches: #{last_name_matches.inspect}"
      # matches = exact_name_matches || fuzzy_name_matches || last_name_matches
      matches = exact_name_matches || last_name_matches || fuzzy_name_matches
      return [] unless matches

      CensusYears.each do |year|
        matches = matches.includes(:"census#{year}_records")
      end
      matches.to_a.select { |match| match.census_records.blank? || match.similar_in_age?(record) }
    end

    private

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

    def exact_name_matches
      cognates = Nicknames.matches_for(first_name, record.sex)
      query = Person.where(sex: record.sex)
                    .where(id: PersonName.select(:person_id)
                                         .where('lower(person_names.first_name) in (?)', cognates)
                                         .where('person_names.last_name % ?', last_name)
                                         .where('person_names.person_id=people.id'))
                    .order('people.first_name, people.middle_name')
      if_exists(query)
    end

    def fuzzy_name_matches
      if_exists(Person.fuzzy_name_search(first_names_with_last_name)
                      .where(sex: record.sex))
    end

    def last_name_matches
      if_exists(Person.where(sex: record.sex)
                      .joins(:names)
                      .where('LOWER(names.last_name) = ? OR LOWER(names.first_name) = ?', last_name, last_name)
                      .order('names.first_name, names.middle_name'))
    end

    def if_exists(matches)
      matches.exists? ? matches.limit(10) : false
    end
  end
end
