# == Schema Information
#
# Table name: census_1910_records
#
#  id                    :integer          not null, primary key
#  data                  :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  building_id           :integer
#  created_by_id         :integer
#  reviewed_by_id        :integer
#  reviewed_at           :datetime
#  person_id             :integer
#  page_number           :integer
#  page_side             :string(1)
#  line_number           :integer
#  county                :string
#  city                  :string
#  state                 :string
#  ward_str              :string
#  enum_dist_str         :string
#  street_prefix         :string
#  street_name           :string
#  street_suffix         :string
#  street_house_number   :string
#  dwelling_number       :string
#  family_id             :string
#  last_name             :string
#  first_name            :string
#  middle_name           :string
#  relation_to_head      :string
#  sex                   :string
#  race                  :string
#  age                   :integer
#  marital_status        :string
#  years_married         :integer
#  num_children_born     :integer
#  num_children_alive    :integer
#  pob                   :string
#  pob_father            :string
#  pob_mother            :string
#  year_immigrated       :integer
#  naturalized_alien     :string
#  occupation            :string           default("None")
#  industry              :string
#  employment            :string
#  unemployed            :boolean
#  attended_school       :boolean
#  can_read              :boolean
#  can_write             :boolean
#  can_speak_english     :boolean
#  owned_or_rented       :string
#  mortgage              :string
#  farm_or_house         :string
#  num_farm_sched        :string
#  language_spoken       :string           default("English")
#  unemployed_weeks_1909 :string
#  civil_war_vet_old     :boolean
#  blind                 :boolean          default(FALSE)
#  deaf_dumb             :boolean          default(FALSE)
#  notes                 :text
#  civil_war_vet         :string(2)
#  provisional           :boolean          default(FALSE)
#  foreign_born          :boolean          default(FALSE)
#  taker_error           :boolean          default(FALSE)
#  name_prefix           :string
#  name_suffix           :string
#  searchable_name       :text
#  apartment_number      :string
#  age_months            :integer
#  mother_tongue         :string
#  mother_tongue_father  :string
#  mother_tongue_mother  :string
#  locality_id           :bigint
#  histid                :uuid
#  enum_dist             :string           not null
#  ward                  :integer
#  institution           :string
#  sortable_name         :string
#
# Indexes
#
#  index_census_1910_records_on_building_id      (building_id)
#  index_census_1910_records_on_created_by_id    (created_by_id)
#  index_census_1910_records_on_data             (data) USING gin
#  index_census_1910_records_on_locality_id      (locality_id)
#  index_census_1910_records_on_person_id        (person_id)
#  index_census_1910_records_on_reviewed_by_id   (reviewed_by_id)
#  index_census_1910_records_on_searchable_name  (searchable_name) USING gin
#

# frozen_string_literal: true

# Model class for 1910 US Census records.
class Census1910Record < CensusRecord
  self.table_name = 'census_1910_records'
  self.year = 1910

  belongs_to :locality, inverse_of: :census1910_records

  validates :pob_father, :pob_mother, vocabulary: { name: :pob, allow_blank: true }
  validates :relation_to_head, vocabulary: { allow_blank: true }, presence: true
  validates :language_spoken, vocabulary: { name: :language, allow_blank: true }
  validates :mother_tongue, :mother_tongue_father, :mother_tongue_mother, vocabulary: { name: :language, allow_blank: true }
  validates :dwelling_number, presence: true
  validates :enum_dist, presence: true

  scope :in_census_order, -> { order :ward, :enum_dist, :page_number, :page_side, :line_number }

  define_enumeration :race, %w[W B Mu Ch Jp In].freeze
  define_enumeration :marital_status, %w[S M_or_M1 M2_or_M3 Wd D].freeze

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
    race: 6,
    sex: 5,
    age: 7,
    age_months: 7,
    marital_status: 8,
    years_married: 9,
    num_children_born: 10,
    num_children_alive: 11,
    pob: 12,
    mother_tongue: 12,
    pob_father: 13,
    mother_tongue_father: 13,
    pob_mother: 14,
    mother_tongue_mother: 14,
    year_immigrated: 15,
    naturalized_alien: 16,
    language_spoken: 17,
    occupation: 18,
    industry: 19,
    employment: 20,
    unemployed: 21,
    unemployed_weeks_1909: 22,
    can_read: 23,
    can_write: 24,
    attended_school: 25,
    owned_or_rented: 26,
    mortgage: 27,
    farm_or_house: 28,
    num_farm_sched: 29,
    civil_war_vet: 30,
    blind: 31,
    dumb: 32
  }.freeze

  IMAGES = {
    page_number: '1910/sheet-side.png',
    page_side: '1910/sheet-side.png',
    ward: '1910/sheet-side.png',
    enum_dist: '1910/sheet-side.png',
    first_name: '1910/names.png',
    middle_name: '1910/names.png',
    last_name: '1910/names.png',
    blind: '1910/punch-card-symbols.png',
    deaf_dumb: '1910/punch-card-symbols.png',
    civil_war_vet: '1910/punch-card-symbols.png'
  }.freeze
end
