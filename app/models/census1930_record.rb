# frozen_string_literal: true

# Model class for 1930 US Census records.
class Census1930Record < CensusRecord
  self.table_name = 'census_1930_records'

  alias_attribute :profession, :occupation
  alias_attribute :profession_code, :occupation_code

  belongs_to :coded_industry, class_name: 'Industry1930Code', optional: true, foreign_key: :industry1930_code_id
  belongs_to :coded_occupation, class_name: 'Occupation1930Code', optional: true, foreign_key: :occupation1930_code_id
  belongs_to :locality, inverse_of: :census1930_records

  before_validation :handle_occupation_code, if: :occupation_code_changed?
  validates :mother_tongue, vocabulary: { name: :language, allow_blank: true }
  validates :dwelling_number, presence: true

  define_enumeration :worker_class, %w[E W OA NP]
  define_enumeration :war_fought, %w[WW Sp Civ Phil Box Mex]
  define_enumeration :race, %w[W Neg Mex In Ch Jp Fil Hin Kor]
  define_enumeration :relation_to_head, %w[Head Wife Son Daughter Lodger Roomer Boarder Sister Servant]
  define_enumeration :name_suffix, %w[Jr Sr]
  define_enumeration :name_prefix, %w[Dr Mr Mrs]

  auto_strip_attributes :industry, :profession_code, :pob_code, :worker_class

  def year
    1930
  end

  def coded_occupation_name
    coded_occupation&.name_with_code
  end

  def coded_industry_name
    coded_industry&.name_with_code
  end

  def handle_occupation_code
    return if occupation_code.blank?

    code = occupation_code.squish.split(' ').join.gsub('O', '0')
    ocode = if code =~ /^(8|9)/
              "#{code[0..1]} #{code[2..3]}"
            else
              code[0..1]
            end
    self.coded_occupation = Occupation1930Code.where(code: ocode).first
    icode = code[-2..]
    self.coded_industry = Industry1930Code.where(code: icode).first
  end

  def validate_profession_code
    return unless occupation_code.present? && (industry1930_code_id.blank? || occupation1930_code_id.blank?)

    errors.add :occupation_code, 'Invalid profession code.'
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
    home_value: 8,
    has_radio: 9,
    lives_on_farm: 10,
    sex: 11,
    race: 12,
    age: 13,
    age_months: 13,
    marital_status: 14,
    age_married: 15,
    attended_school: 16,
    can_read_write: 17,
    pob: 18,
    pob_father: 19,
    pob_mother: 20,
    mother_tongue: 21,
    year_immigrated: 22,
    naturalized_alien: 23,
    can_speak_english: 24,
    occupation: 25,
    industry: 26,
    worker_class: 27,
    occupation_code: 'D',
    worked_yesterday: 28,
    unemployment_line: 29,
    veteran: 30,
    war_fought: 31,
    farm_schedule: 32
  }.freeze

  IMAGES = {
    page_number: '1930/enum.png',
    page_side: '1930/enum.png',
    enum_dist: '1930/enum.png',
    first_name: '1910/names.png',
    middle_name: '1910/names.png',
    last_name: '1910/names.png',
    ward: '1930/ward.png',
    homemaker: '1930/homemaker.png'
  }.freeze
end
