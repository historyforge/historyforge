# frozen_string_literal: true

module People
  class LikelyMatches < ApplicationInteraction
    include FastMemoize
    object :record, class: 'CensusRecord'

    def execute
      # puts "Exact Matches: #{exact_name_matches.inspect}"
      # puts "Fuzzy Matches: #{fuzzy_name_matches.inspect}"
      # puts "Last Name Matches: #{last_name_matches.inspect}"
      matches = exact_name_matches || fuzzy_name_matches || last_name_matches
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
      if_exists(Person.where(sex: record.sex)
                      .joins(:names)
                      .where('(LOWER(names.last_name) = ? AND LOWER(names.first_name) = ?) OR (LOWER(names.first_name) = ? AND LOWER(names.last_name) = ?)', last_name, first_name, last_name, first_name)
                      .order('names.first_name, names.middle_name'))
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
