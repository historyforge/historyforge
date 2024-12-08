# == Schema Information
#
# Table name: people
#
#  id                      :integer          not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  last_name               :string
#  first_name              :string
#  middle_name             :string
#  sex                     :string(12)
#  race                    :string
#  name_prefix             :string
#  name_suffix             :string
#  searchable_name         :text
#  birth_year              :integer
#  is_birth_year_estimated :boolean          default(TRUE)
#  pob                     :string
#  is_pob_estimated        :boolean          default(TRUE)
#  notes                   :text
#  description             :text
#  sortable_name           :string
#
# Indexes
#
#  people_name_trgm  (searchable_name) USING gist
#

# frozen_string_literal: true

FactoryBot.define do
  factory(:person) do
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    sex { 'M' }
    race { 'W' }

    after(:build) do |person, evaluator|
      if evaluator.first_name || evaluator.middle_name || evaluator.last_name
        name_attrs = {
          first_name: evaluator.first_name,
          middle_name: evaluator.middle_name,
          last_name: evaluator.last_name,
          name_prefix: evaluator.name_prefix,
          name_suffix: evaluator.name_suffix
        }.compact_blank
        person.names << FactoryBot.build(:person_name, is_primary: true, **name_attrs)
      elsif evaluator.name
        person.names << evaluator.name
      end
    end

    after(:create) do |person|
      person.remove_instance_variable :@census_records if person.instance_variable_defined?(:@census_records)
    end
  end
end
