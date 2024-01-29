# == Schema Information
#
# Table name: census_1880_records
#
#  id                  :bigint           not null, primary key
#  locality_id         :bigint
#  building_id         :bigint
#  person_id           :bigint
#  created_by_id       :bigint
#  reviewed_by_id      :bigint
#  reviewed_at         :datetime
#  page_number         :integer
#  page_side           :string(1)
#  line_number         :integer
#  county              :string
#  city                :string
#  state               :string
#  ward_str            :string
#  enum_dist_str       :string
#  street_house_number :string
#  street_prefix       :string
#  street_name         :string
#  street_suffix       :string
#  apartment_number    :string
#  dwelling_number     :string
#  family_id           :string
#  last_name           :string
#  first_name          :string
#  middle_name         :string
#  name_prefix         :string
#  name_suffix         :string
#  sex                 :string
#  race                :string
#  age                 :integer
#  age_months          :integer
#  birth_month         :integer
#  relation_to_head    :string
#  marital_status      :string
#  just_married        :boolean
#  occupation          :string           default("None")
#  unemployed_months   :integer
#  sick                :string
#  blind               :boolean
#  deaf_dumb           :boolean
#  idiotic             :boolean
#  insane              :boolean
#  maimed              :boolean
#  attended_school     :boolean
#  cannot_read         :boolean
#  cannot_write        :boolean
#  pob                 :string
#  pob_father          :string
#  pob_mother          :string
#  notes               :text
#  provisional         :boolean          default(FALSE)
#  foreign_born        :boolean          default(FALSE)
#  taker_error         :boolean          default(FALSE)
#  farm_schedule       :integer
#  searchable_name     :text
#  histid              :uuid
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  enum_dist           :string           not null
#  ward                :integer
#  institution         :string
#  sortable_name       :string
#
# Indexes
#
#  index_census_1880_records_on_building_id      (building_id)
#  index_census_1880_records_on_created_by_id    (created_by_id)
#  index_census_1880_records_on_locality_id      (locality_id)
#  index_census_1880_records_on_person_id        (person_id)
#  index_census_1880_records_on_reviewed_by_id   (reviewed_by_id)
#  index_census_1880_records_on_searchable_name  (searchable_name) USING gist
#

# frozen_string_literal: true

# Model class for 1880 US Census records.
class Census1880Record < CensusRecord
  self.table_name = 'census_1880_records'
  self.year = 1880

  belongs_to :locality, inverse_of: :census1880_records

  validates :relation_to_head, vocabulary: { allow_blank: true }, presence: true
  validates :pob_father, :pob_mother, vocabulary: { name: :pob, allow_blank: true }
  validates :enum_dist, presence: true

  scope :in_census_order, -> { order :ward, :enum_dist, :page_number, :page_side, :line_number }

  define_enumeration :page_side, %w[A B C D], strict: true
  define_enumeration :race, %w[W B Mu Ch In]

  def self.translate_race_code(code)
    return 'C' if code == 'Ch'
    return 'I' if code == 'In'

    code
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
    relation_to_head: 8,
    race: 4,
    sex: 5,
    birth_month: 7,
    age: 6,
    age_months: 6,
    marital_status: '9-11',
    just_married: 12,
    pob: 24,
    pob_father: 25,
    pob_mother: 26,
    occupation: 13,
    unemployed_months: 14,
    attended_school: 21,
    cannot_read: 22,
    cannot_write: 23,
    sick: 15,
    blind: 16,
    deaf_dumb: 17,
    idiotic: 18,
    insane: 19,
    maimed: 20
  }.freeze

  IMAGES = {
    page_number: '1880/enum.png',
    page_side: '1880/side-a.png',
    enum_dist: '1880/enum.png',
    first_name: '1910/names.png',
    middle_name: '1910/names.png',
    last_name: '1910/names.png'
  }.freeze
end
