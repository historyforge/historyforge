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
#  index_census_1870_records_on_searchable_name  (searchable_name) USING gist
#
FactoryBot.define do
  factory :census1870_record do
    
  end
end
