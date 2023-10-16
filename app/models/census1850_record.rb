# == Schema Information
#
# Table name: census_1850_records
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
#
# Indexes
#
#  index_census_1850_records_on_building_id     (building_id)
#  index_census_1850_records_on_created_by_id   (created_by_id)
#  index_census_1850_records_on_locality_id     (locality_id)
#  index_census_1850_records_on_person_id       (person_id)
#  index_census_1850_records_on_reviewed_by_id  (reviewed_by_id)
#
class Census1850Record < CensusRecord
  self.table_name = 'census_1850_records'
  self.year = 1850

  belongs_to :locality, inverse_of: :census1850_records
  scope :in_census_order, -> { order :ward, :page_number, :page_side, :line_number }

  define_enumeration :race, %w[W B]

  def page_side?
    false
  end

  def per_page
    42
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
    age: 4,
    age_months: 4,
    sex: 5,
    race: 6,
    occupation: 7,
    home_value: 8,
    pob: 9,
    just_married: 10,
    attended_school: 11,
    cannot_read_write: 12,
    blind: 13,
    deaf_dumb: 13,
    idiotic: 13,
    insane: 13,
    pauper: 13,
    convict: 13
  }.freeze

  IMAGES = {
    first_name: '1850/names.png',
    middle_name: '1850/names.png',
    last_name: '1850/names.png'
  }.freeze
end
