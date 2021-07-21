class Census1940Record < CensusRecord
  self.table_name = 'census_1940_records'

  belongs_to :locality, inverse_of: :census1940_records

  alias_attribute :profession, :occupation
  alias_attribute :profession_code, :occupation_code

  validate :validate_occupation_codes

  define_enumeration :marital_status, %w{S M (M)7 Wd D}
  define_enumeration :worker_class, %w{PW GW E OA NP}
  define_enumeration :race, %w{W Neg In Ch Jp Fil Hin Kor}
  define_enumeration :name_suffix, %w{Jr Sr}
  define_enumeration :name_prefix, %w{Dr Mr Mrs}
  define_enumeration :grade_completed, %w{0 1 2 3 4 5 6 7 8 H-1 H-2 H-3 H-4 C-1 C-2 C-3 C-4 C-5}
  define_enumeration :naturalized_alien, %w{Na Pa Al AmCit}
  define_enumeration :war_fought, %w{W S SW R}
  define_enumeration :no_work_reason, %w{H S U Ot}
  define_enumeration :deduction_rate, %w{1 2 3}
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

  def self.folder_name
    'census_records_nineteen_forty'
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
end
