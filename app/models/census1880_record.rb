# frozen_string_literal: true

class Census1880Record < CensusRecord
  belongs_to :locality, inverse_of: :census1880_records

  define_enumeration :race, %w[W B Mu Ch In]

  alias_attribute :profession, :occupation

  def year
    1880
  end

  COLUMNS = {
    street_house_number: '2nd Column on the Left',
    street_prefix: '1st Column on the Left',
    street_name: '1st Column on the Left',
    street_suffix: '1st Column on the Left',
    dwelling_number: 1,
    family_id: 2,
    last_name: 3,
    first_name: 3,
    middle_name: 3,
    name_prefix: 3,
    name_suffix: 3,
    relation_to_head: 8,
    race: 4,
    sex: 5,
    birth_month: 7,
    age: 6,
    age_months: 6,
    marital_status: '9-11',
    just_married: 12,
    pob: 24,
    pob_father: 25,
    pob_mother: 26,
    occupation: 13,
    unemployed_months: 14,
    attended_school: 21,
    cannot_read: 22,
    cannot_write: 23,
    sick: 15,
    blind: 16,
    deaf_dumb: 17,
    idiotic: 18,
    insane: 19,
    maimed: 20
  }.freeze
end
