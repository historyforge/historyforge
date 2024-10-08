# == Schema Information
#
# Table name: census_1870_records
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
#  post_office         :string
#  state               :string
#  ward                :integer
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
#  age                 :integer
#  age_months          :integer
#  sex                 :string
#  race                :string
#  occupation          :string           default("None")
#  home_value          :integer
#  personal_value      :integer
#  pob                 :string
#  father_foreign_born :boolean
#  mother_foreign_born :boolean
#  attended_school     :boolean
#  cannot_read         :boolean
#  cannot_write        :boolean
#  deaf_dumb           :boolean
#  blind               :boolean
#  insane              :boolean
#  idiotic             :boolean
#  full_citizen        :boolean
#  denied_citizen      :boolean
#  notes               :text
#  foreign_born        :boolean          default(FALSE)
#  taker_error         :boolean          default(FALSE)
#  farm_schedule       :integer
#  searchable_name     :text
#  histid              :uuid
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  birth_month         :integer
#  marriage_month      :integer
#  institution         :string
#  sortable_name       :string
#
# Indexes
#
#  index_census_1870_records_on_building_id      (building_id)
#  index_census_1870_records_on_created_by_id    (created_by_id)
#  index_census_1870_records_on_locality_id      (locality_id)
#  index_census_1870_records_on_person_id        (person_id)
#  index_census_1870_records_on_reviewed_by_id   (reviewed_by_id)
#  index_census_1870_records_on_searchable_name  (searchable_name) USING gin
#
class Census1870Record < CensusRecord
  self.table_name = 'census_1870_records'
  self.year = 1870

  belongs_to :locality, inverse_of: :census1870_records
  validates :post_office, presence: true
  scope :in_census_order, -> { order :ward, :page_number, :page_side, :line_number }

  define_enumeration :race, %w[W B Mu Ch In].freeze

  def self.translate_race_code(code)
    return 'M' if code == 'Mu'
    return 'C' if code == 'Ch'
    return 'I' if code == 'In'

    code
  end

  def page_side?
    false
  end

  def per_page
    40
  end

  COLUMNS = {
    dwelling_number: 1,
    family_id: 2,
    last_name: 3,
    first_name: 3,
    middle_name: 3,
    name_prefix: 3,
    name_suffix: 3,
    age: 4,
    age_months: 4,
    sex: 5,
    race: 6,
    occupation: 7,
    home_value: 8,
    personal_value: 9,
    pob: 10,
    father_foreign_born: 11,
    mother_foreign_born: 12,
    birth_month: 13,
    marriage_month: 14,
    attended_school: 15,
    cannot_read: 16,
    cannot_write: 17,
    blind: 18,
    deaf_dumb: 18,
    idiotic: 18,
    insane: 18,
    pauper: 18,
    convict: 18,
    full_citizen: 19,
    denied_citizen: 20
  }.freeze

  IMAGES = {
    first_name: '1870/names.png',
    middle_name: '1870/names.png',
    last_name: '1870/names.png'
  }.freeze
end
