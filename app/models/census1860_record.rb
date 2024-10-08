# == Schema Information
#
# Table name: census_1860_records
#
#  id                   :bigint           not null, primary key
#  locality_id          :bigint
#  building_id          :bigint
#  person_id            :bigint
#  created_by_id        :bigint
#  reviewed_by_id       :bigint
#  reviewed_at          :datetime
#  page_number          :integer
#  page_side            :string(1)
#  line_number          :integer
#  county               :string
#  city                 :string
#  post_office          :string
#  institution_name     :string
#  institution_type     :string
#  state                :string
#  ward                 :integer
#  street_house_number  :string
#  street_prefix        :string
#  street_name          :string
#  street_suffix        :string
#  apartment_number     :string
#  dwelling_number      :string
#  family_id            :string
#  last_name            :string
#  first_name           :string
#  middle_name          :string
#  name_prefix          :string
#  name_suffix          :string
#  age                  :integer
#  age_months           :integer
#  sex                  :string
#  race                 :string
#  occupation           :string           default("None")
#  home_value           :integer
#  personal_value       :integer
#  pob                  :string
#  just_married         :boolean
#  attended_school      :boolean
#  cannot_read_write    :boolean
#  deaf_dumb            :boolean
#  blind                :boolean
#  insane               :boolean
#  idiotic              :boolean
#  pauper               :boolean
#  convict              :boolean
#  nature_of_misfortune :string
#  year_of_misfortune   :integer
#  notes                :text
#  foreign_born         :boolean          default(FALSE)
#  taker_error          :boolean          default(FALSE)
#  farm_schedule        :integer
#  searchable_name      :text
#  histid               :uuid
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  sortable_name        :string
#
# Indexes
#
#  index_census_1860_records_on_building_id      (building_id)
#  index_census_1860_records_on_created_by_id    (created_by_id)
#  index_census_1860_records_on_locality_id      (locality_id)
#  index_census_1860_records_on_person_id        (person_id)
#  index_census_1860_records_on_reviewed_by_id   (reviewed_by_id)
#  index_census_1860_records_on_searchable_name  (searchable_name) USING gin
#
class Census1860Record < CensusRecord
  self.table_name = 'census_1860_records'
  self.year = 1860

  belongs_to :locality, inverse_of: :census1860_records
  validates :post_office, presence: true
  scope :in_census_order, -> { order :ward, :page_number, :page_side, :line_number }

  define_enumeration :race, %w[W B Mu Ind].freeze

  def self.translate_race_code(code)
    return 'M' if code == 'Mu'

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
    just_married: 11,
    attended_school: 12,
    cannot_read_write: 13,
    blind: 14,
    deaf_dumb: 14,
    idiotic: 14,
    insane: 14,
    pauper: 14,
    convict: 14
  }.freeze

  IMAGES = {
    first_name: '1850/names.png',
    middle_name: '1850/names.png',
    last_name: '1850/names.png'
  }.freeze
end
