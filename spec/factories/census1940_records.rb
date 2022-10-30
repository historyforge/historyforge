# frozen_string_literal: true

# == Schema Information
#
# Table name: census_1940_records
#
#  id                      :bigint           not null, primary key
#  building_id             :bigint
#  person_id               :bigint
#  created_by_id           :bigint
#  reviewed_by_id          :bigint
#  reviewed_at             :datetime
#  page_number             :integer
#  page_side               :string(1)
#  line_number             :integer
#  county                  :string
#  city                    :string
#  state                   :string
#  ward_str                :string
#  enum_dist_str           :string
#  apartment_number        :string
#  street_prefix           :string
#  street_name             :string
#  street_suffix           :string
#  street_house_number     :string
#  dwelling_number         :string
#  family_id               :string
#  last_name               :string
#  first_name              :string
#  middle_name             :string
#  name_prefix             :string
#  name_suffix             :string
#  searchable_name         :text
#  owned_or_rented         :string
#  home_value              :decimal(, )
#  lives_on_farm           :boolean
#  relation_to_head        :string
#  sex                     :string
#  race                    :string
#  age                     :integer
#  age_months              :integer
#  marital_status          :string
#  attended_school         :boolean
#  grade_completed         :string
#  pob                     :string
#  naturalized_alien       :string
#  residence_1935_town     :string
#  residence_1935_county   :string
#  residence_1935_state    :string
#  residence_1935_farm     :boolean
#  private_work            :boolean
#  public_work             :boolean
#  seeking_work            :boolean
#  had_job                 :boolean
#  no_work_reason          :string
#  private_hours_worked    :integer
#  unemployed_weeks        :integer
#  occupation              :string           default("None")
#  industry                :string
#  worker_class            :string
#  occupation_code         :string
#  full_time_weeks         :integer
#  income                  :integer
#  had_unearned_income     :boolean
#  farm_schedule           :string
#  pob_father              :string
#  pob_mother              :string
#  mother_tongue           :string
#  veteran                 :boolean
#  veteran_dead            :boolean
#  war_fought              :string
#  soc_sec                 :boolean
#  deductions              :boolean
#  deduction_rate          :string
#  usual_occupation        :string
#  usual_industry          :string
#  usual_worker_class      :string
#  usual_occupation_code   :string
#  usual_industry_code     :string
#  usual_worker_class_code :string
#  multi_marriage          :boolean
#  first_marriage_age      :integer
#  children_born           :integer
#  notes                   :text
#  provisional             :boolean          default(FALSE)
#  foreign_born            :boolean          default(FALSE)
#  taker_error             :boolean          default(FALSE)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  worker_class_code       :string
#  industry_code           :string
#  locality_id             :bigint
#  histid                  :uuid
#  enum_dist               :integer
#  ward                    :integer
#  income_plus             :boolean
#
# Indexes
#
#  index_census_1940_records_on_building_id     (building_id)
#  index_census_1940_records_on_created_by_id   (created_by_id)
#  index_census_1940_records_on_locality_id     (locality_id)
#  index_census_1940_records_on_person_id       (person_id)
#  index_census_1940_records_on_reviewed_by_id  (reviewed_by_id)
#
FactoryBot.define do
  factory(:census1940_record) do
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
    # mother_tongue { 'English' }
  end
end
