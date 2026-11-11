# frozen_string_literal: true

module People
  class LikelyMatches
    AGE_TOLERANCE = 5
    MAX_MATCHES = 20
    MAX_SURNAME_ONLY_MATCHES = 10

    # Allow a weaker surname spelling match when a given name or known nickname agrees.
    SURNAME_SIMILARITY_WITH_GIVEN_NAME = 0.25

    REASONS = {
      1 => 'Same given or middle name and surname',
      2 => 'Known nickname and same surname',
      3 => 'Similar given or middle name and same surname',
      4 => 'Matching given name or nickname and similar surname',
      5 => 'Similar given or middle name and similar surname',
      6 => 'Given name and surname appear reversed',
      7 => 'Same surname only',
    }.freeze

    def self.call(record:)
      new(record:).call
    end

    def initialize(record:)
      @record = record
    end

    def call
      return { matches: [], reasons: {} } if record.first_name.blank? || record.last_name.blank?
      return { matches: [], reasons: {} } if CensusRecords::OnlyOneCensusYear.call

      ranked = ranked_people.limit(MAX_MATCHES).preload(*CensusYears.map { |year| :"census#{year}_records" }).to_a
      supported, surname_only = ranked.partition { |person| person.name_match_rank != REASONS.size }
      matches = supported.presence || surname_only.first(MAX_SURNAME_ONLY_MATCHES)

      { matches:, reasons: matches.to_h { |person| [person.id, REASONS.fetch(person.name_match_rank)] } }
    end

    private

    attr_reader :record

    def given_names
      # A middle initial can be absent or transcribed differently across censuses.
      middle_name = record.middle_name.to_s.downcase
      names = [record.first_name.downcase]
      names << middle_name if middle_name.length > 1
      names.uniq
    end

    def birth_year_from_age
      age = record.age
      record.year - age if age && age >= 0 && age != 999
    end

    def ranked_people
      eligible = Person.where(sex: record.sex)
      birth_year = birth_year_from_age
      if birth_year
        eligible = eligible.where(birth_year: [nil, (birth_year - AGE_TOLERANCE)..(birth_year + AGE_TOLERANCE)])
      end

      name_ranks = PersonName.where(person_id: eligible.select(:id)).select(:person_id, Arel.sql(name_rank_sql))
      people = Person.with(name_ranks:)
                     .joins(<<~SQL.squish)
                       INNER JOIN (
                         SELECT person_id, MIN(name_match_rank) AS name_match_rank
                         FROM name_ranks
                         WHERE name_match_rank IS NOT NULL
                         GROUP BY person_id
                       ) best_name ON best_name.person_id = people.id
                     SQL
                     .select('people.*', 'best_name.name_match_rank')
                     .order('best_name.name_match_rank')

      people = people.order(Arel.sql('ABS(people.birth_year - ?) ASC NULLS LAST', birth_year)) if birth_year
      people.order(:last_name, :first_name, :middle_name, :id)
    end

    def name_rank_sql
      names = given_names
      nicknames = names.flat_map { |name| Nicknames.matches_for(name, record.sex) }.uniq
      same_surname = 'LOWER(person_names.last_name) = :surname'
      same_given = '(LOWER(person_names.first_name) IN (:names) OR LOWER(person_names.middle_name) IN (:names))'
      known_given = '(LOWER(person_names.first_name) IN (:nicknames) OR LOWER(person_names.middle_name) IN (:nicknames))'
      similar_given = names.map do |name|
        PersonName.sanitize_sql_array(['(person_names.first_name % ? OR person_names.middle_name % ?)', name, name])
      end.join(' OR ')

      PersonName.sanitize_sql_array([<<~SQL, { names:, nicknames:, surname: record.last_name.downcase, minimum: SURNAME_SIMILARITY_WITH_GIVEN_NAME }])
        CASE
          WHEN #{same_surname} AND #{same_given} THEN 1
          WHEN #{same_surname} AND #{known_given} THEN 2
          WHEN #{same_surname} AND (#{similar_given}) THEN 3
          WHEN #{known_given} AND similarity(person_names.last_name, :surname) >= :minimum THEN 4
          WHEN person_names.last_name % :surname AND (#{similar_given}) THEN 5
          WHEN LOWER(person_names.first_name) = :surname AND LOWER(person_names.last_name) IN (:names) THEN 6
          WHEN #{same_surname} THEN 7
        END AS name_match_rank
      SQL
    end
  end
end
