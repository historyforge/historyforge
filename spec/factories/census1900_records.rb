# frozen_string_literal: true

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
FactoryBot.define do
  factory(:census1900_record) do
    city { 'Ithaca' }
    county { 'Tompkins' }
    state { 'New York' }
    sequence(:first_name) { |n| "First#{n}" }
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
    language_spoken { 'English' }
  end
end
