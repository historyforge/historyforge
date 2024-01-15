# frozen_string_literal: true

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
#
# Indexes
#
#  census_1930_records_name_trgm                        (searchable_name) USING gist
#  index_census_1930_records_on_building_id             (building_id)
#  index_census_1930_records_on_created_by_id           (created_by_id)
#  index_census_1930_records_on_industry1930_code_id    (industry1930_code_id)
#  index_census_1930_records_on_locality_id             (locality_id)
#  index_census_1930_records_on_occupation1930_code_id  (occupation1930_code_id)
#  index_census_1930_records_on_person_id               (person_id)
#  index_census_1930_records_on_reviewed_by_id          (reviewed_by_id)
#
FactoryBot.define do
  factory(:census1930_record) do
    city { 'Ithaca' }
    county { 'Tompkins' }
    state { 'New York' }
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:middle_name) { |n| "Middle#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    sex { 'M' }
    race { 'W' }
    occupation { 'None' }
    family_id { 1 }
    relation_to_head { 'Head' }
    page_number { 1 }
    page_side { 'A' }
    sequence(:line_number) { |n| n + 1 }
    enum_dist { 1 }
    locality
    dwelling_number { 1 }
    mother_tongue { 'English' }
  end
end
