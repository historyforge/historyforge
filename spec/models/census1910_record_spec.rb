# frozen_string_literal: true

# == Schema Information
#
# Table name: census_1910_records
#
#  id                    :integer          not null, primary key
#  data                  :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  building_id           :integer
#  created_by_id         :integer
#  reviewed_by_id        :integer
#  reviewed_at           :datetime
#  person_id             :integer
#  page_number           :integer
#  page_side             :string(1)
#  line_number           :integer
#  county                :string
#  city                  :string
#  state                 :string
#  ward_str              :string
#  enum_dist_str         :string
#  street_prefix         :string
#  street_name           :string
#  street_suffix         :string
#  street_house_number   :string
#  dwelling_number       :string
#  family_id             :string
#  last_name             :string
#  first_name            :string
#  middle_name           :string
#  relation_to_head      :string
#  sex                   :string
#  race                  :string
#  age                   :integer
#  marital_status        :string
#  years_married         :integer
#  num_children_born     :integer
#  num_children_alive    :integer
#  pob                   :string
#  pob_father            :string
#  pob_mother            :string
#  year_immigrated       :integer
#  naturalized_alien     :string
#  occupation            :string           default("None")
#  industry              :string
#  employment            :string
#  unemployed            :boolean
#  attended_school       :boolean
#  can_read              :boolean
#  can_write             :boolean
#  can_speak_english     :boolean
#  owned_or_rented       :string
#  mortgage              :string
#  farm_or_house         :string
#  num_farm_sched        :string
#  language_spoken       :string           default("English")
#  unemployed_weeks_1909 :string
#  civil_war_vet_old     :boolean
#  blind                 :boolean          default(FALSE)
#  deaf_dumb             :boolean          default(FALSE)
#  notes                 :text
#  civil_war_vet         :string(2)
#  provisional           :boolean          default(FALSE)
#  foreign_born          :boolean          default(FALSE)
#  taker_error           :boolean          default(FALSE)
#  name_prefix           :string
#  name_suffix           :string
#  searchable_name       :text
#  apartment_number      :string
#  age_months            :integer
#  mother_tongue         :string
#  mother_tongue_father  :string
#  mother_tongue_mother  :string
#  locality_id           :bigint
#  histid                :uuid
#  enum_dist             :string           not null
#  ward                  :integer
#  institution           :string
#  sortable_name         :string
#
# Indexes
#
#  index_census_1910_records_on_building_id      (building_id)
#  index_census_1910_records_on_created_by_id    (created_by_id)
#  index_census_1910_records_on_data             (data) USING gin
#  index_census_1910_records_on_locality_id      (locality_id)
#  index_census_1910_records_on_person_id        (person_id)
#  index_census_1910_records_on_reviewed_by_id   (reviewed_by_id)
#  index_census_1910_records_on_searchable_name  (searchable_name) USING gin
#
require 'rails_helper'

RSpec.describe Census1910Record do
  context 'with auto generation of person record' do
    context 'when there are multiple censuses going' do
      let(:record) { build(:census1910_record) }

      before do
        create(:census1920_record)
        record.save && record.review!(create(:user))
      end

      it 'does not generate a person record automatically' do
        expect(record.person).to be_nil
      end
    end

    context 'when it is the very first census record ever' do
      let(:record) { build(:census1910_record) }

      before do
        create(:census1910_record)
        record.save && record.review!(create(:user))
      end

      it 'generates a person record automatically' do
        expect(record.person).not_to be_nil
      end
    end

    context 'when there is only one census going' do
      let(:record) { build(:census1910_record) }

      before { record.save && record.review!(create(:user)) }

      it 'generates a person record automatically' do
        expect(record.person).not_to be_nil
      end
    end
  end
end
