# frozen_string_literal: true

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
#  enum_dist            :integer
#  ward                 :integer
#
# Indexes
#
#  census_1920_records_name_trgm             (searchable_name) USING gist
#  index_census_1920_records_on_building_id  (building_id)
#  index_census_1920_records_on_locality_id  (locality_id)
#  index_census_1920_records_on_person_id    (person_id)
#
FactoryBot.define do
  factory(:census1920_record) do
    city { 'Ithaca' }
    county { 'Tompkins' }
    state { 'New York' }
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:middle_name) { |n| "Middle#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    sex { 'M' }
    race { 'W' }
    profession { 'None' }
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
