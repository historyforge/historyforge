# == Schema Information
#
# Table name: census_1930_records
#
#  id                     :integer          not null, primary key
#  building_id            :integer
#  person_id              :integer
#  created_by_id          :integer
#  reviewed_by_id         :integer
#  reviewed_at            :datetime
#  page_number            :integer
#  page_side              :string(1)
#  line_number            :integer
#  county                 :string
#  city                   :string
#  state                  :string
#  ward_str               :string
#  enum_dist_str          :string
#  street_prefix          :string
#  street_name            :string
#  street_suffix          :string
#  street_house_number    :string
#  dwelling_number        :string
#  family_id              :string
#  last_name              :string
#  first_name             :string
#  middle_name            :string
#  relation_to_head       :string
#  owned_or_rented        :string
#  home_value             :decimal(, )
#  has_radio              :boolean
#  lives_on_farm          :boolean
#  sex                    :string
#  race                   :string
#  age                    :integer
#  marital_status         :string
#  age_married            :integer
#  attended_school        :boolean
#  can_read_write         :boolean
#  pob                    :string
#  pob_father             :string
#  pob_mother             :string
#  pob_code               :string
#  pob_father_code        :string
#  pob_mother_code        :string
#  mother_tongue          :string
#  year_immigrated        :integer
#  naturalized_alien      :string
#  can_speak_english      :boolean
#  occupation             :string           default("None")
#  industry               :string
#  occupation_code        :string
#  worker_class           :string
#  worked_yesterday       :boolean
#  unemployment_line      :string
#  veteran                :boolean
#  war_fought             :string
#  farm_schedule          :string
#  notes                  :text
#  provisional            :boolean          default(FALSE)
#  foreign_born           :boolean          default(FALSE)
#  taker_error            :boolean          default(FALSE)
#  created_at             :datetime
#  updated_at             :datetime
#  name_prefix            :string
#  name_suffix            :string
#  searchable_name        :text
#  has_radio_int          :integer
#  lives_on_farm_int      :integer
#  attended_school_int    :integer
#  can_read_write_int     :integer
#  can_speak_english_int  :integer
#  worked_yesterday_int   :integer
#  veteran_int            :integer
#  foreign_born_int       :integer
#  homemaker_int          :integer
#  age_months             :integer
#  apartment_number       :string
#  homemaker              :boolean
#  industry1930_code_id   :bigint
#  occupation1930_code_id :bigint
#  locality_id            :bigint
#  histid                 :uuid
#  enum_dist              :string           not null
#  ward                   :integer
#  institution            :string
#  sortable_name          :string
#
# Indexes
#
#  index_census_1930_records_on_building_id             (building_id)
#  index_census_1930_records_on_created_by_id           (created_by_id)
#  index_census_1930_records_on_industry1930_code_id    (industry1930_code_id)
#  index_census_1930_records_on_locality_id             (locality_id)
#  index_census_1930_records_on_occupation1930_code_id  (occupation1930_code_id)
#  index_census_1930_records_on_person_id               (person_id)
#  index_census_1930_records_on_reviewed_by_id          (reviewed_by_id)
#  index_census_1930_records_on_searchable_name         (searchable_name) USING gin
#

# frozen_string_literal: true

# Model class for 1930 US Census records.
class Census1930Record < CensusRecord
  self.table_name = 'census_1930_records'
  self.year = 1930

  belongs_to :coded_industry, class_name: 'Industry1930Code', optional: true, foreign_key: :industry1930_code_id
  belongs_to :coded_occupation, class_name: 'Occupation1930Code', optional: true, foreign_key: :occupation1930_code_id
  belongs_to :locality, inverse_of: :census1930_records

  before_validation :handle_occupation_code, if: :occupation_code_changed?
  validates :relation_to_head, vocabulary: { allow_blank: true }, presence: true
  validates :pob_father, :pob_mother, vocabulary: { name: :pob, allow_blank: true }
  validates :mother_tongue, vocabulary: { name: :language, allow_blank: true }
  validates :dwelling_number, presence: true
  validates :enum_dist, presence: true

  scope :in_census_order, -> { order :ward, :enum_dist, :page_number, :page_side, :line_number }

  define_enumeration :worker_class, %w[E W OA NP].freeze
  define_enumeration :war_fought, %w[WW Sp Civ Phil Box Mex].freeze
  define_enumeration :race, %w[W B Mex In Ch Jp Fil Hin Kor].freeze
  define_enumeration :name_suffix, %w[Jr Sr].freeze
  define_enumeration :name_prefix, %w[Dr Mr Mrs].freeze

  auto_upcase_attributes :occupation_code

  def self.translate_race_code(code)
    return 'Neg' if code == 'B'

    code
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
