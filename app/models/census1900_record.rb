# frozen_string_literal: true

# Model class for 1900 US Census records.
class Census1900Record < CensusRecord
  self.table_name = 'census_1900_records'

  alias_attribute :profession, :occupation

  belongs_to :locality, inverse_of: :census1900_records

  validates :attended_school, :years_in_us, :years_married,
            :num_children_born, :num_children_alive, :unemployed_months,
            :birth_month, :birth_year, :age, :age_months,
            numericality: { greater_than_or_equal_to: -1, allow_blank: true }

  validates :language_spoken, vocabulary: { name: :language, allow_blank: true }
  validates :dwelling_number, presence: true

  auto_strip_attributes :industry

  define_enumeration :race, %w[W B Ch Jp In]

  def year
    1900
  end

  def birth_month=(value)
    value = 999 if value == 'unknown'
    write_attribute(:birth_month, value)
  end

  def birth_month
    value = read_attribute(:birth_month)
    value == 999 ? 'unknown' : value
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
    relation_to_head: 4,
    race: 5,
    sex: 6,
    birth_month: 7,
    birth_year: 7,
    age: 8,
    age_months: 8,
    marital_status: 9,
    years_married: 10,
    num_children_born: 11,
    num_children_alive: 12,
    pob: 13,
    pob_father: 14,
    pob_mother: 15,
    year_immigrated: 16,
    years_in_us: 17,
    naturalized_alien: 18,
    occupation: 19,
    industry: 19,
    unemployed_months: 20,
    attended_school: 21,
    can_read: 22,
    can_write: 23,
    can_speak_english: 24,
    owned_or_rented: 25,
    mortgage: 26,
    farm_or_house: 27,
    farm_schedule: 28
  }.freeze

  IMAGES = {
    page_number: '1900/sheet-side.png',
    page_side: '1900/sheet-side.png',
    ward: '1900/sheet-side.png',
    enum_dist: '1900/sheet-side.png',
    first_name: '1910/names.png',
    middle_name: '1910/names.png',
    last_name: '1910/names.png',
  }.freeze
end
