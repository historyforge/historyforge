# frozen_string_literal: true

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
#
# Indexes
#
#  index_census_1880_records_on_building_id     (building_id)
#  index_census_1880_records_on_created_by_id   (created_by_id)
#  index_census_1880_records_on_locality_id     (locality_id)
#  index_census_1880_records_on_person_id       (person_id)
#  index_census_1880_records_on_reviewed_by_id  (reviewed_by_id)
#
FactoryBot.define do
  factory :census1880_record do
  end
end
