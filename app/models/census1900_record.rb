# == Schema Information
#
# Table name: census_1900_records
#
#  id                  :integer          not null, primary key
#  data                :jsonb
#  building_id         :integer
#  person_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  created_by_id       :integer
#  reviewed_by_id      :integer
#  reviewed_at         :datetime
#  page_number         :integer
#  page_side           :string(1)
#  line_number         :integer
#  county              :string
#  city                :string
#  state               :string
#  ward_str            :string
#  enum_dist_str       :string
#  street_prefix       :string
#  street_name         :string
#  street_suffix       :string
#  street_house_number :string
#  dwelling_number     :string
#  family_id           :string
#  last_name           :string
#  first_name          :string
#  middle_name         :string
#  relation_to_head    :string
#  sex                 :string
#  race                :string
#  birth_month         :integer
#  birth_year          :integer
#  age                 :integer
#  marital_status      :string
#  years_married       :integer
#  num_children_born   :integer
#  num_children_alive  :integer
#  pob                 :string
#  pob_father          :string
#  pob_mother          :string
#  year_immigrated     :integer
#  naturalized_alien   :string
#  years_in_us         :integer
#  occupation          :string           default("None")
#  unemployed_months   :integer
#  attended_school_old :boolean
#  can_read            :boolean
#  can_write           :boolean
#  can_speak_english   :boolean
#  owned_or_rented     :string
#  mortgage            :string
#  farm_or_house       :string
#  language_spoken     :string           default("English")
#  notes               :text
#  provisional         :boolean          default(FALSE)
#  foreign_born        :boolean          default(FALSE)
#  taker_error         :boolean          default(FALSE)
#  attended_school     :integer
#  industry            :string
#  farm_schedule       :integer
#  name_prefix         :string
#  name_suffix         :string
#  searchable_name     :text
#  apartment_number    :string
#  age_months          :integer
#  locality_id         :bigint
#  histid              :uuid
#  enum_dist           :string           not null
#  ward                :integer
#  institution         :string
#  sortable_name       :string
#
# Indexes
#
#  census_1900_records_name_trgm             (searchable_name) USING gist
#  index_census_1900_records_on_building_id  (building_id)
#  index_census_1900_records_on_data         (data) USING gin
#  index_census_1900_records_on_locality_id  (locality_id)
#  index_census_1900_records_on_person_id    (person_id)
#

# frozen_string_literal: true

# Model class for 1900 US Census records.
class Census1900Record < CensusRecord
  self.table_name = 'census_1900_records'
  self.year = 1900

  belongs_to :locality, inverse_of: :census1900_records

  validates :relation_to_head, vocabulary: { allow_blank: true }, presence: true
  validates :pob_father, :pob_mother, vocabulary: { name: :pob, allow_blank: true }
  validates :attended_school, :years_in_us, :years_married,
            :num_children_born, :num_children_alive, :unemployed_months,
            :birth_month, :birth_year, :age, :age_months,
            numericality: { greater_than_or_equal_to: -1, allow_blank: true }

  validates :language_spoken, vocabulary: { name: :language, allow_blank: true }
  validates :dwelling_number, presence: true
  validates :enum_dist, presence: true

  scope :in_census_order, -> { order :ward, :enum_dist, :page_number, :page_side, :line_number }

  define_enumeration :race, %w[W B Ch Jp In].freeze

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
