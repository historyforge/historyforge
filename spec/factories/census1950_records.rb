# == Schema Information
#
# Table name: census1950_records
#
#  id                     :integer          not null, primary key
#  locality_id            :integer
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
#  ward                   :integer
#  enum_dist              :integer
#  institution_name       :string
#  institution_type       :string
#  apartment_number       :string
#  street_prefix          :string
#  street_name            :string
#  street_suffix          :string
#  street_house_number    :string
#  dwelling_number        :string
#  family_id              :string
#  lives_on_farm          :boolean
#  lives_on_3_acres       :boolean
#  ag_questionnaire_no    :string
#  last_name              :string
#  first_name             :string
#  middle_name            :string
#  name_prefix            :string
#  name_suffix            :string
#  searchable_name        :text
#  relation_to_head       :string
#  race                   :string
#  sex                    :string
#  age                    :integer
#  marital_status         :string
#  pob                    :string
#  foreign_born           :boolean          default("false")
#  naturalized_alien      :string
#  activity_last_week     :string
#  worked_last_week       :boolean
#  seeking_work           :boolean
#  employed_absent        :boolean
#  hours_worked           :integer
#  occupation             :string           default("None")
#  industry               :string
#  worker_class           :string
#  occupation_code        :string
#  industry_code          :string
#  worker_class_code      :string
#  same_house_1949        :boolean
#  on_farm_1949           :boolean
#  same_county_1949       :boolean
#  county_1949            :string
#  state_1949             :string
#  pob_father             :string
#  pob_mother             :string
#  highest_grade          :string
#  finished_grade         :boolean
#  attended_school        :string
#  weeks_seeking_work     :integer
#  weeks_worked           :integer
#  wages_or_salary_self   :string
#  own_business_self      :string
#  unearned_income_self   :string
#  wages_or_salary_family :string
#  own_business_family    :string
#  unearned_income_family :string
#  veteran_ww2            :boolean
#  veteran_ww1            :boolean
#  veteran_other          :boolean
#  item_20_entries        :boolean
#  last_occupation        :string
#  last_industry          :string
#  last_worker_class      :string
#  multi_marriage         :boolean
#  years_married          :integer
#  newlyweds              :boolean
#  children_born          :integer
#  notes                  :text
#  provisional            :boolean          default("false")
#  taker_error            :boolean          default("false")
#  histid                 :uuid
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  birth_month            :integer
#  attended_school_bool   :boolean          default("false")
#
# Indexes
#
#  index_census1950_records_on_building_id     (building_id)
#  index_census1950_records_on_created_by_id   (created_by_id)
#  index_census1950_records_on_locality_id     (locality_id)
#  index_census1950_records_on_person_id       (person_id)
#  index_census1950_records_on_reviewed_by_id  (reviewed_by_id)
#

FactoryBot.define do
  factory :census1950_record do
    
  end
end
