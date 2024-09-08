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
FactoryBot.define do
  factory :census1860_record do
    
  end
end
