# frozen_string_literal: true

# Model class for 1920 US Census records.
class Census1920Record < CensusRecord

  self.table_name = 'census_1920_records'

  alias_attribute :profession, :occupation

  belongs_to :locality, inverse_of: :census1920_records

  validates :mother_tongue, :mother_tongue_father, :mother_tongue_mother, vocabulary: { name: :language, allow_blank: true }
  validates :dwelling_number, presence: true

  define_enumeration :employment, %w[W Em OA]
  define_enumeration :race, %w[W B Mu In Ch Jp Fil Hin Kor Ot]

  auto_strip_attributes :industry, :employment, :employment_code

  def year
    1920
  end

  COLUMNS = {
    street_house_number: 2,
    street_prefix: 1,
    street_name: 1,
    street_suffix: 1,
    dwelling_number: 3,
    family_id: 4,
    last_name: 5,
    first_name: 5,
    middle_name: 5,
    name_prefix: 5,
    name_suffix: 5,
    relation_to_head: 6,
    owned_or_rented: 7,
    mortgage: 8,
    sex: 9,
    race: 10,
    age: 11,
    age_months: 11,
    marital_status: 12,
    year_immigrated: 13,
    naturalized_alien: 14,
    year_naturalized: 15,
    attended_school: 16,
    can_read: 17,
    can_write: 18,
    pob: 19,
    mother_tongue: 20,
    pob_father: 21,
    mother_tongue_father: 22,
    pob_mother: 23,
    mother_tongue_mother: 24,
    speaks_english: 25,
    occupation: 26,
    industry: 27,
    employment: 28,
    farm_schedule: 29,
    employment_code: 'Right Margin'
  }.freeze

  IMAGES = {
    page_number: '1920/sheet-side.png',
    page_side: '1920/sheet-side.png',
    ward: '1920/sheet-side.png',
    enum_dist: '1920/sheet-side.png',
    first_name: '1920/names.png',
    middle_name: '1920/names.png',
    last_name: '1920/names.png'
  }.freeze
end
