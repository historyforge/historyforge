# frozen_string_literal: true

class CensusRecordEntity < BaseEntity

  attribute :id, :integer
  attribute :age_months, :integer
  attribute :age, :integer
  attribute :apartment_number, :string
  attribute :attended_school, :string
  attribute :building_id, :integer
  attribute :can_read, :string
  attribute :can_speak_english, :string
  attribute :can_write, :string
  attribute :census_person_id, :integer
  attribute :city, :string
  attribute :county, :string
  attribute :created_at, :datetime
  attribute :dwelling_number, :string
  attribute :employment_code, :string
  attribute :employment, :string
  attribute :family_id, :integer
  attribute :farm_or_house, :string
  attribute :farm_schedule, :string
  attribute :first_name, :string
  attribute :foreign_born, :string
  attribute :gender, :string
  attribute :histid, :string
  attribute :industry, :string
  attribute :institution, :string
  attribute :last_name, :string
  attribute :locality_id, :integer
  attribute :marital_status, :string
  attribute :middle_name, :string
  attribute :mortgage, :string
  attribute :mother_tongue_father, :string
  attribute :mother_tongue_mother, :string
  attribute :mother_tongue, :string
  attribute :name_prefix, :string
  attribute :name_suffix, :string
  attribute :naturalized_alien, :string
  attribute :notes, :string
  attribute :occupation, :string
  attribute :owned_or_rented, :string
  attribute :person_id, :integer
  attribute :pob_father, :string
  attribute :pob_mother, :string
  attribute :pob, :string
  attribute :provisional, :boolean
  attribute :race, :string
  attribute :relation_to_head, :string
  attribute :searchable_name, :string
  attribute :scope, :string
  attribute :sex, :string
  attribute :sortable_name, :string
  attribute :state, :string
  attribute :street_house_number, :string
  attribute :street_name, :string
  attribute :street_prefix, :string
  attribute :street_suffix, :string
  attribute :taker_error, :boolean
  attribute :updated_at, :datetime
  attribute :year_immigrated, :integer
  attribute :year_naturalized, :integer
  attribute :year, :integer

  def self.build_from(census_record, year)
    return nil if census_record.nil?

    census_record = census_record.decorate if census_record.respond_to?(:decorate)

    new(
      id: census_record.id,
      age_months: census_record.age_months,
      age: census_record.age,
      apartment_number: census_record.apartment_number,
      attended_school: census_record.attended_school,
      building_id: census_record.building_id,
      can_read: census_record.can_read,
      can_speak_english: census_record.can_speak_english,
      can_write: census_record.can_write,
      census_person_id: census_record.census_person_id,
      city: census_record.city,
      county: census_record.county,
      created_at: census_record.created_at,
      dwelling_number: census_record.dwelling_number,
      employment_code: census_record.employment_code,
      employment: census_record.employment,
      family_id: census_record.family_id,
      farm_or_house: census_record.farm_or_house,
      farm_schedule: census_record.farm_schedule,
      first_name: census_record.first_name,
      foreign_born: census_record.foreign_born,
      gender: census_record.gender,
      histid: census_record.histid,
      industry: census_record.industry,
      institution: census_record.institution,
      last_name: census_record.last_name,
      locality_id: census_record.locality_id,
      marital_status: census_record.marital_status,
      middle_name: census_record.middle_name,
      mortgage: census_record.mortgage,
      mother_tongue_father: census_record.mother_tongue_father,
      mother_tongue_mother: census_record.mother_tongue_mother,
      mother_tongue: census_record.mother_tongue,
      name_prefix: census_record.name_prefix,
      name_suffix: census_record.name_suffix,
      naturalized_alien: census_record.naturalized_alien,
      notes: census_record.notes,
      occupation: census_record.occupation,
      owned_or_rented: census_record.owned_or_rented,
      person_id: census_record.person_id,
      pob_father: census_record.pob_father,
      pob_mother: census_record.pob_mother,
      pob: census_record.pob,
      provisional: census_record.provisional,
      race: census_record.race,
      relation_to_head: census_record.relation_to_head,
      searchable_name: census_record.searchable_name,
      scope: census_record.census_scope,
      sex: census_record.sex,
      sortable_name: census_record.sortable_name,
      state: census_record.state,
      street_house_number: census_record.street_house_number,
      street_name: census_record.street_name,
      street_prefix: census_record.street_prefix,
      street_suffix: census_record.street_suffix,
      taker_error: census_record.taker_error,
      updated_at: census_record.updated_at,
      year_immigrated: census_record.year_immigrated,
      year_naturalized: census_record.year_naturalized,
      year: year
    )
  end

  def to_h
    attributes.compact
  end
end
