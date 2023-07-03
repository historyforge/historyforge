class Census1870Record < CensusRecord
  self.table_name = 'census_1870_records'
  self.year = 1870

  belongs_to :locality, inverse_of: :census1870_records
  validates :post_office, presence: true

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
    father_foreign_born: 11,
    mother_foreign_born: 12,
    just_born: 13,
    just_married: 14,
    attended_school: 15,
    cannot_read: 16,
    cannot_write: 17,
    blind: 18,
    deaf_dumb: 18,
    idiotic: 18,
    insane: 18,
    pauper: 18,
    convict: 18,
    full_citizen: 19,
    denied_citizen: 20
  }.freeze

  IMAGES = {
    first_name: '1910/names.png',
    middle_name: '1910/names.png',
    last_name: '1910/names.png'
  }.freeze
end
