# == Schema Information
#
# Table name: census_1920_records
#
#  id                   :integer          not null, primary key
#  created_by_id        :integer
#  reviewed_by_id       :integer
#  reviewed_at          :datetime
#  page_number          :integer
#  page_side            :string(1)
#  line_number          :integer
#  county               :string
#  city                 :string
#  state                :string
#  ward_str             :string
#  enum_dist_str        :string
#  street_prefix        :string
#  street_name          :string
#  street_suffix        :string
#  street_house_number  :string
#  dwelling_number      :string
#  family_id            :string
#  last_name            :string
#  first_name           :string
#  middle_name          :string
#  relation_to_head     :string
#  sex                  :string
#  race                 :string
#  age                  :integer
#  marital_status       :string
#  year_immigrated      :integer
#  naturalized_alien    :string
#  pob                  :string
#  mother_tongue        :string
#  pob_father           :string
#  mother_tongue_father :string
#  pob_mother           :string
#  mother_tongue_mother :string
#  can_speak_english    :boolean
#  occupation           :string           default("None")
#  industry             :string
#  employment           :string
#  attended_school      :boolean
#  can_read             :boolean
#  can_write            :boolean
#  owned_or_rented      :string
#  mortgage             :string
#  farm_or_house        :string
#  notes                :text
#  provisional          :boolean          default(FALSE)
#  foreign_born         :boolean          default(FALSE)
#  taker_error          :boolean          default(FALSE)
#  person_id            :integer
#  building_id          :integer
#  created_at           :datetime
#  updated_at           :datetime
#  name_prefix          :string
#  name_suffix          :string
#  year_naturalized     :integer
#  farm_schedule        :integer
#  searchable_name      :text
#  apartment_number     :string
#  age_months           :integer
#  employment_code      :string
#  locality_id          :bigint
#  histid               :uuid
#  enum_dist            :string           not null
#  ward                 :integer
#  institution          :string
#  sortable_name        :string
#
# Indexes
#
#  census_1920_records_name_trgm             (searchable_name) USING gist
#  index_census_1920_records_on_building_id  (building_id)
#  index_census_1920_records_on_locality_id  (locality_id)
#  index_census_1920_records_on_person_id    (person_id)
#

# frozen_string_literal: true

# Model class for 1920 US Census records.
class Census1920Record < CensusRecord
  self.table_name = 'census_1920_records'
  self.year = 1920

  belongs_to :locality, inverse_of: :census1920_records

  validates :relation_to_head, vocabulary: { allow_blank: true }, presence: true
  validates :pob_father, :pob_mother, vocabulary: { name: :pob, allow_blank: true }
  validates :mother_tongue, :mother_tongue_father, :mother_tongue_mother, vocabulary: { name: :language, allow_blank: true }
  validates :dwelling_number, presence: true
  validates :enum_dist, presence: true

  scope :in_census_order, -> { order :ward, :enum_dist, :page_number, :page_side, :line_number }

  define_enumeration :employment, %w[W Em OA].freeze
  define_enumeration :race, %w[W B Mu In Ch Jp Fil Hin Kor].freeze

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
