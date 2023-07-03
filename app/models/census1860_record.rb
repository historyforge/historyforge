class Census1860Record < CensusRecord
  self.table_name = 'census_1860_records'
  self.year = 1860

  belongs_to :locality, inverse_of: :census1860_records

  define_enumeration :race, %w[W B Mu]

  def page_side?
    false
  end

  def per_page
    40
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
    age: 4,
    age_months: 4,
    sex: 5,
    race: 6,
    occupation: 7,
    home_value: 8,
    personal_value: 9,
    pob: 10,
    just_married: 11,
    attended_school: 12,
    cannot_read_write: 13,
    blind: 14,
    deaf_dumb: 14,
    idiotic: 14,
    insane: 14,
    pauper: 14,
    convict: 14
  }.freeze

  IMAGES = {
    first_name: '1910/names.png',
    middle_name: '1910/names.png',
    last_name: '1910/names.png'
  }.freeze
end
