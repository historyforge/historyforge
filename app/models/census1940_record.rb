# frozen_string_literal: true

# Model class for 1940 US Census records.
class Census1940Record < CensusRecord
  self.table_name = 'census_1940_records'

  belongs_to :locality, inverse_of: :census1940_records

  alias_attribute :profession, :occupation
  alias_attribute :profession_code, :occupation_code

  validate :validate_occupation_codes

  define_enumeration :marital_status, %w[S M (M)7 Wd D]
  define_enumeration :worker_class, %w[PW GW E OA NP]
  define_enumeration :race, %w[W Neg In Ch Jp Fil Hin Kor]
  define_enumeration :name_suffix, %w[Jr Sr]
  define_enumeration :name_prefix, %w[Dr Mr Mrs]
  define_enumeration :grade_completed, %w[0 1 2 3 4 5 6 7 8 H-1 H-2 H-3 H-4 C-1 C-2 C-3 C-4 C-5]
  define_enumeration :naturalized_alien, %w[Na Pa Al AmCit]
  define_enumeration :war_fought, %w[W S SW R]
  define_enumeration :no_work_reason, %w[H S U Ot]
  define_enumeration :deduction_rate, %w[1 2 3]
  auto_strip_attributes :industry, :occupation_code, :worker_class

  def year
    1940
  end

  def per_side
    40
  end

  def per_page
    80
  end

  def supplemental?
    mother_tongue.present?
  end

  def validate_code(field)
    value = public_send(field)
    return unless value

    if value =~ /[a-zA-UWYZ]/
      errors.add field, 'can only have letters V or X'
    end
    if value =~ /\W/
      errors.add field, 'can only have digits and V or X'
    end
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
    usual_profession: 45,
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
