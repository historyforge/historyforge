class Census1850Record < CensusRecord
  self.table_name = 'census_1850_records'
  self.year = 1850

  belongs_to :locality, inverse_of: :census1850_records

  define_enumeration :race, %w[W B Mu]

  def page_side?
    false
  end

  def per_page
    42
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
    pob: 9,
    just_married: 10,
    attended_school: 11,
    cannot_read_write: 12,
    blind: 13,
    deaf_dumb: 13,
    idiotic: 13,
    insane: 13,
    pauper: 13,
    convict: 13
  }.freeze

  IMAGES = {
    first_name: '1910/names.png',
    middle_name: '1910/names.png',
    last_name: '1910/names.png'
  }.freeze
end
