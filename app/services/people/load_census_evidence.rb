# frozen_string_literal: true

module People
  # Prepares the census rows and households a caller has authorized for a Person.
  class LoadCensusEvidence
    Result = Data.define(:census_records, :census_households)

    def self.call(person:, readable:)
      new(person:, readable:).call
    end

    def initialize(person:, readable:)
      @person = person
      @readable = readable
    end

    def call
      census_records = @person.census_records.select(&@readable)
      census_households = census_records.index_with { |record| CensusHousehold.call(record:, readable: @readable) }
      members = census_households.values.flat_map(&:members).select(&:person_id)
      ActiveRecord::Associations::Preloader.new(records: members, associations: :person).call
      Result.new(census_records:, census_households:)
    end
  end
end
