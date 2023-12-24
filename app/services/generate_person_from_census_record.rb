# frozen_string_literal: true

class GeneratePersonFromCensusRecord
  include FastMemoize

  def initialize(census_record)
    @census_record = census_record
  end

  attr_reader :census_record
  delegate :year, to: :census_record

  def perform
    census_record.update person_id: person.id
    person
  end

  def person
    @person = Person.new "census#{year}_records" => [census_record]
    @person.race = census_record.race
    @person.sex = census_record.sex
    @person.birth_year = census_record.year - census_record.age if census_record.age&.< 120
    @person.pob = census_record.pob
    @person.add_name_from(census_record)
    @person.save
    @person
  end
  memoize :person
end
