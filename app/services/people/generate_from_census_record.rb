# frozen_string_literal: true

module People
  class GenerateFromCensusRecord < ApplicationInteraction
    # @!attribute census_record [CensusRecord]
    object :record, class: 'CensusRecord'

    def execute
      person = person_from_census_record
      person.save
      record.update person_id: person.id
      person
    end

    def person_from_census_record
      person = Person.new "census#{record.year}_records" => [record]
      person.race = record.race
      person.sex = record.sex
      person.birth_year = record.year - record.age if record.age&.< 120
      person.pob = record.pob
      person.add_locality_from(record)
      person.add_name_from(record)
      person
    end
  end
end
