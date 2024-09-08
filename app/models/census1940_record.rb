# == Schema Information
#
# Table name: census_1940_records
#
#  id                      :bigint           not null, primary key
#  building_id             :bigint
#  person_id               :bigint
#  created_by_id           :bigint
#  reviewed_by_id          :bigint
#  reviewed_at             :datetime
#  page_number             :integer
#  page_side               :string(1)
#  line_number             :integer
#  county                  :string
#  city                    :string
#  state                   :string
#  ward_str                :string
#  enum_dist_str           :string
#  apartment_number        :string
#  street_prefix           :string
#  street_name             :string
#  street_suffix           :string
#  street_house_number     :string
#  dwelling_number         :string
#  family_id               :string
#  last_name               :string
#  first_name              :string
#  middle_name             :string
#  name_prefix             :string
#  name_suffix             :string
#  searchable_name         :text
#  owned_or_rented         :string
#  home_value              :decimal(, )
#  lives_on_farm           :boolean
#  relation_to_head        :string
#  sex                     :string
#  race                    :string
#  age                     :integer
#  age_months              :integer
#  marital_status          :string
#  attended_school         :boolean
#  grade_completed         :string
#  pob                     :string
#  naturalized_alien       :string
#  residence_1935_town     :string
#  residence_1935_county   :string
#  residence_1935_state    :string
#  residence_1935_farm     :boolean
#  private_work            :boolean
#  public_work             :boolean
#  seeking_work            :boolean
#  had_job                 :boolean
#  no_work_reason          :string
#  private_hours_worked    :integer
#  unemployed_weeks        :integer
#  occupation              :string           default("None")
#  industry                :string
#  worker_class            :string
#  occupation_code         :string
#  full_time_weeks         :integer
#  income                  :integer
#  had_unearned_income     :boolean
#  farm_schedule           :string
#  pob_father              :string
#  pob_mother              :string
#  mother_tongue           :string
#  veteran                 :boolean
#  veteran_dead            :boolean
#  war_fought              :string
#  soc_sec                 :boolean
#  deductions              :boolean
#  deduction_rate          :string
#  usual_occupation        :string
#  usual_industry          :string
#  usual_worker_class      :string
#  usual_occupation_code   :string
#  usual_industry_code     :string
#  usual_worker_class_code :string
#  multi_marriage          :boolean
#  first_marriage_age      :integer
#  children_born           :integer
#  notes                   :text
#  provisional             :boolean          default(FALSE)
#  foreign_born            :boolean          default(FALSE)
#  taker_error             :boolean          default(FALSE)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  worker_class_code       :string
#  industry_code           :string
#  locality_id             :bigint
#  histid                  :uuid
#  enum_dist               :string           not null
#  ward                    :integer
#  income_plus             :boolean
#  wages_or_salary         :string
#  institutional_work      :boolean
#  institution             :string
#  sortable_name           :string
#
# Indexes
#
#  index_census_1940_records_on_building_id     (building_id)
#  index_census_1940_records_on_created_by_id   (created_by_id)
#  index_census_1940_records_on_locality_id     (locality_id)
#  index_census_1940_records_on_person_id       (person_id)
#  index_census_1940_records_on_reviewed_by_id  (reviewed_by_id)
#

# frozen_string_literal: true

# Model class for 1940 US Census records.
class Census1940Record < CensusRecord
  self.table_name = 'census_1940_records'
  self.year = 1940

  belongs_to :locality, inverse_of: :census1940_records

  before_validation :translate_income
  validates :relation_to_head, vocabulary: { allow_blank: true }, presence: true
  validates :pob_father, :pob_mother, vocabulary: { name: :pob, allow_blank: true }
  validates :enum_dist, presence: true
  validate :validate_occupation_codes

  scope :in_census_order, -> { order :ward, :enum_dist, :page_number, :page_side, :line_number }

  define_enumeration :marital_status, %w[S M (M)7 Wd D].freeze
  define_enumeration :worker_class, %w[PW GW E OA NP NW].freeze
  define_enumeration :race, %w[W B In Ch Jp Fil Hin Kor].freeze
  define_enumeration :name_suffix, %w[Jr Sr].freeze
  define_enumeration :name_prefix, %w[Dr Mr Mrs].freeze
  define_enumeration :grade_completed, %w[0 1 2 3 4 5 6 7 8 H-1 H-2 H-3 H-4 C-1 C-2 C-3 C-4 C-5].freeze
  define_enumeration :naturalized_alien, %w[Na Pa Al AmCit].freeze
  define_enumeration :war_fought, %w[W S SW R].freeze
  define_enumeration :no_work_reason, %w[H S U Ot].freeze
  define_enumeration :deduction_rate, %w[1 2 3].freeze
  define_enumeration :wages_or_salary, %w[5000+].freeze

  auto_upcase_attributes :occupation_code, :usual_occupation_code,
                         :usual_industry_code, :worker_class_code, :usual_worker_class_code

  def self.translate_race_code(code)
    return 'Neg' if code == 'B'
    return 'Chi' if code == 'Ch'

    code
  end

  def per_side
    40
  end

  def per_page
    80
  end

  def supplemental?
    new_record? || mother_tongue.present? || line_number == 14 || line_number == 29
  end

  def validate_code(field)
    value = public_send(field)
    return unless value

    errors.add field, 'can only have letters V or X' if value =~ /[a-zA-UWYZ]/
    errors.add field, 'can only have digits and V or X' if value =~ /\W/
  end

  def validate_worker_class_code(field)
    value = public_send(field)
    value = nil if value.blank?
    return unless value

    errors.add(field, 'can only be 1 through 6') if value !~ /[1-6]/
  end

  def validate_occupation_codes
    validate_code(:occupation_code)
    validate_code(:industry_code)
    validate_worker_class_code(:worker_class_code)
    validate_code(:usual_occupation_code)
    validate_code(:usual_industry_code)
    validate_worker_class_code(:usual_worker_class_code)
  end

  def translate_income
    return if wages_or_salary.present? || income.blank?

    self.wages_or_salary = if income == 999
      'Un'
    elsif income_plus?
      '5000+'
    elsif income.nil?
      nil
    else
      income.to_s
    end
  end

  COLUMNS = {
    street_house_number: 2,
    street_prefix: 1,
    street_name: 1,
    street_suffix: 1,
    family_id: 3,
    owned_or_rented: 4,
    home_value: 5,
    lives_on_farm: 6,
    last_name: 7,
    first_name: 7,
    middle_name: 7,
    name_prefix: 7,
    name_suffix: 7,
    relation_to_head: 8,
    sex: 9,
    race: 10,
    age: 11,
    age_months: 11,
    marital_status: 12,
    attended_school: 13,
    grade_completed: 14,
    pob: 15,
    naturalized_alien: 16,
    residence_1935_town: 17,
    residence_1935_county: 18,
    residence_1935_state: 19,
    residence_1935_farm: 20,
    private_work: 21,
    public_work: 22,
    seeking_work: 23,
    had_job: 24,
    no_work_reason: 25,
    private_hours_worked: 26,
    unemployed_weeks: 27,
    occupation: 28,
    industry: 29,
    worker_class: 30,
    occupation_code: 'F',
    industry_code: 'F',
    worker_class_code: 'F',
    full_time_weeks: 31,
    income: 32,
    income_plus: 32,
    had_unearned_income: 33,
    farm_schedule: 34,
    pob_father: 36,
    pob_mother: 37,
    mother_tongue: 38,
    veteran: 39,
    veteran_dead: 40,
    war_fought: 41,
    soc_sec: 42,
    deductions: 43,
    deduction_rate: 44,
    usual_occupation: 45,
    usual_industry: 46,
    usual_worker_class: 47,
    usual_occupation_code: 'J',
    usual_industry_code: 'J',
    usual_worker_class_code: 'J',
    multi_marriage: 48,
    first_marriage_age: 49,
    children_born: 50
  }.freeze

  IMAGES = {
    page_number: '1940/sheet-side.png',
    page_side: '1940/sheet-side.png',
    ward: '1940/ward.png',
    enum_dist: '1940/sheet-side.png',
    first_name: '1940/names.png',
    middle_name: '1940/names.png',
    last_name: '1940/names.png',
    grade_completed: '1940/grade-completed.png',
    citizenship: '1920/citizenship.png',
    occupation_code: '1940/occupation-codes.png',
    industry_code: '1940/occupation-codes.png',
    worker_class_code: '1940/occupation-codes.png',
    usual_occupation_code: '1940/occupation-codes.png',
    usual_industry_code: '1940/occupation-codes.png',
    usual_worker_class_code: '1940/occupation-codes.png',
  }.freeze
end
