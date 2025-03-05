# == Schema Information
#
# Table name: census_1950_records
#
#  id                     :bigint           not null, primary key
#  locality_id            :bigint
#  building_id            :bigint
#  person_id              :bigint
#  created_by_id          :bigint
#  reviewed_by_id         :bigint
#  reviewed_at            :datetime
#  page_number            :integer
#  page_side              :string(1)
#  line_number            :integer
#  county                 :string
#  city                   :string
#  state                  :string
#  ward                   :integer
#  enum_dist              :string           not null
#  institution_name       :string
#  institution_type       :string
#  apartment_number       :string
#  street_prefix          :string
#  street_name            :string
#  street_suffix          :string
#  street_house_number    :string
#  dwelling_number        :string
#  family_id              :string
#  lives_on_farm          :boolean
#  lives_on_3_acres       :boolean
#  ag_questionnaire_no    :string
#  last_name              :string
#  first_name             :string
#  middle_name            :string
#  name_prefix            :string
#  name_suffix            :string
#  searchable_name        :text
#  relation_to_head       :string
#  race                   :string
#  sex                    :string
#  age                    :integer
#  marital_status         :string
#  pob                    :string
#  foreign_born           :boolean          default(FALSE)
#  naturalized_alien      :string
#  activity_last_week     :string
#  worked_last_week       :boolean
#  seeking_work           :boolean
#  employed_absent        :boolean
#  hours_worked           :integer
#  occupation             :string           default("None")
#  industry               :string
#  worker_class           :string
#  occupation_code        :string
#  industry_code          :string
#  worker_class_code      :string
#  same_house_1949        :boolean
#  on_farm_1949           :boolean
#  same_county_1949       :boolean
#  county_1949            :string
#  state_1949             :string
#  pob_father             :string
#  pob_mother             :string
#  highest_grade          :string
#  finished_grade         :boolean
#  weeks_seeking_work     :integer
#  weeks_worked           :integer
#  wages_or_salary_self   :string
#  own_business_self      :string
#  unearned_income_self   :string
#  wages_or_salary_family :string
#  own_business_family    :string
#  unearned_income_family :string
#  veteran_ww2            :boolean
#  veteran_ww1            :boolean
#  veteran_other          :boolean
#  item_20_entries        :boolean
#  last_occupation        :string
#  last_industry          :string
#  last_worker_class      :string
#  multi_marriage         :boolean
#  years_married          :integer
#  newlyweds              :boolean
#  children_born          :integer
#  notes                  :text
#  provisional            :boolean          default(FALSE)
#  taker_error            :boolean          default(FALSE)
#  histid                 :uuid
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  birth_month            :integer
#  attended_school        :boolean          default(FALSE)
#  sortable_name          :string
#
# Indexes
#
#  index_census_1950_records_on_building_id      (building_id)
#  index_census_1950_records_on_created_by_id    (created_by_id)
#  index_census_1950_records_on_locality_id      (locality_id)
#  index_census_1950_records_on_person_id        (person_id)
#  index_census_1950_records_on_reviewed_by_id   (reviewed_by_id)
#  index_census_1950_records_on_searchable_name  (searchable_name) USING gin
#

# frozen_string_literal: true

# Model class for 1940 US Census record
class Census1950Record < CensusRecord
  self.table_name = "census_1950_records"
  self.year = 1950

  belongs_to :locality, inverse_of: :census1950_records

  validates :relation_to_head, vocabulary: { allow_blank: true }, presence: true
  validates :pob_father, :pob_mother, vocabulary: { name: :pob, allow_blank: true }
  validates :enum_dist, presence: true
  validate :validate_occupation_codes

  scope :in_census_order, -> { order :ward, :enum_dist, :page_number, :page_side, :line_number }

  define_enumeration :page_side, %w[A B C D].freeze, strict: true
  define_enumeration :marital_status, %w[Nev Mar Wd D Sep].freeze
  define_enumeration :race, %w[W B In Ch Jp Fil].freeze
  define_enumeration :name_suffix, %w[Jr Sr].freeze
  define_enumeration :name_prefix, %w[Dr Mr Mrs].freeze
  define_enumeration :activity_last_week, %w[Wk H U Ot Inmate].freeze
  define_enumeration :worker_class, %w[P G O NP].freeze
  define_enumeration :last_worker_class, %w[P G O NP].freeze
  define_enumeration :naturalized_alien, %w[Y N AP].freeze
  define_enumeration :highest_grade, %w[0 K S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 C1 C2 C3 C4 C5].freeze

  income_enumeration = %w[10000+]
  define_enumeration :wages_or_salary_self, income_enumeration.dup.concat(["P6"]).freeze
  define_enumeration :own_business_self, income_enumeration.freeze
  define_enumeration :unearned_income_self, income_enumeration.freeze
  define_enumeration :wages_or_salary_family, income_enumeration.freeze
  define_enumeration :own_business_family, income_enumeration.freeze
  define_enumeration :unearned_income_family, income_enumeration.freeze

  auto_upcase_attributes :occupation_code, :industry_code, :worker_class_code

  def self.translate_race_code(code)
    return "Neg" if code == "B"
    return "Ind" if code == "In"
    return "Chi" if code == "Ch"
    return "Jap" if code == "Jp"

    code
  end

  def per_side
    40
  end

  def per_page
    80
  end

  def page_side?
    false
  end

  def page_side_optional?
    true
  end

  def supplemental?
    new_record? || pob_father?
  end

  def validate_code(field)
    value = public_send(field)
    return unless value

    errors.add field, "can only have letters V or X" if /[a-zA-UWYZ]/.match?(value)
    errors.add field, "can only have digits and V or X" if /\W/.match?(value)
  end

  def validate_worker_class_code(field)
    value = public_send(field)
    value = nil if value.blank?
    return unless value

    errors.add(field, "can only be 1 through 6") unless /[1-6]/.match?(value)
  end

  def validate_occupation_codes
    validate_code(:occupation_code)
    validate_code(:industry_code)
    validate_worker_class_code(:worker_class_code)
  end

  COLUMNS = {
    street_house_number: 2,
    street_prefix: 1,
    street_name: 1,
    street_suffix: 1,
    family_id: 3,
    lives_on_farm: 4,
    lives_on_3_acres: 5,
    ag_questionnaire_no: 6,
    last_name: 7,
    first_name: 7,
    middle_name: 7,
    name_prefix: 7,
    name_suffix: 7,
    relation_to_head: 8,
    race: 9,
    sex: 10,
    age: 11,
    age_months: 11,
    marital_status: 12,
    pob: 13,
    naturalized_alien: 14,
    activity_last_week: 15,
    worked_last_week: 16,
    seeking_work: 17,
    employed_absent: 18,
    hours_worked: 19,
    occupation: "Item 20a",
    industry: "Item 20b",
    worker_class: "Item 20c",
    occupation_code: "Item C",
    industry_code: "Item C",
    worker_class_code: "Item C",
    same_house_1949: 21,
    on_farm_1949: 22,
    same_county_1949: 23,
    county_1949: "Item 24a",
    state_1949: "Item 24b",
    pob_father: "Item 25a",
    pob_mother: "Item 25b",
    highest_grade: 26,
    finished_grade: 27,
    weeks_seeking_work: 29,
    weeks_worked: 30,
    wages_or_salary_self: "Item 31a",
    wages_or_salary_family: "Item 32a",
    own_business_self: "Item 31b",
    own_business_family: "Item 32b",
    unearned_income_self: "Item 31c",
    unearned_income_family: "Item 32c",
    veteran_ww2: "Item 33a",
    veteran_ww1: "Item 33b",
    veteran_other: "Item 33c",
    item_20_entries: 34,
    last_occupation: "Item 35a",
    last_industry: "Item 35b",
    last_worker_class: "Item 35c",
    multi_marriage: 36,
    years_married: 37,
    children_born: 38,
  }.freeze

  IMAGES = {
    page_number: "1950/sheet-side.png",
    page_side: "1950/sheet-side.png",
    ward: "1940/ward.png",
    enum_dist: "1950/enum.png",
    first_name: "1940/names.png",
    middle_name: "1940/names.png",
    last_name: "1940/names.png",
    grade_completed: "1940/grade-completed.png",
    citizenship: "1920/citizenship.png",
    occupation_code: "1940/occupation-codes.png",
    industry_code: "1940/occupation-codes.png",
    worker_class_code: "1940/occupation-codes.png",
    usual_occupation_code: "1940/occupation-codes.png",
    usual_industry_code: "1940/occupation-codes.png",
    usual_worker_class_code: "1940/occupation-codes.png",
  }.freeze
end
