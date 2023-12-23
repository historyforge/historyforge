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
    %i[name_prefix name_suffix first_name middle_name last_name sex race].each do |attr|
      @person[attr] = census_record[attr]
    end
    @person.birth_year = census_record.year - census_record.age if census_record.age&.< 120
    @person.pob = census_record.pob
    @person.save
    @person.add_name_from(census_record)
    @person
  end
  memoize :person
end
