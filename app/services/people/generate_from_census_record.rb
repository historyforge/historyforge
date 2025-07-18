# frozen_string_literal: true

module People
  class GenerateFromCensusRecord < ApplicationInteraction
    # @!attribute census_record [CensusRecord]
    object :record, class: 'CensusRecord'

    def execute
      person = person_from_census_record
      person.save!
      record.update!(person_id: person.id)
      person
    end

    def person_from_census_record
      # Create person without associations first to avoid premature callbacks
      person = Person.new

      # Set all attributes before adding associations
      person.first_name = record.first_name
      person.middle_name = record.middle_name
      person.last_name = record.last_name
      person.name_prefix = record.name_prefix
      person.name_suffix = record.name_suffix
      person.race = record.race
      person.sex = record.sex
      person.birth_year = record.year - record.age if record.age&.< 120
      person.pob = record.pob

      # Add the census record association after attributes are set
      person.send("census#{record.year}_records") << record

      # Add locality and name after all core attributes are set
      person.add_locality_from(record)
      person.add_name_from(record)

      person
    end
  end
end
