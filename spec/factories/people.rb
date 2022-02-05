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
#  race                    :string(12)
#  name_prefix             :string
#  name_suffix             :string
#  searchable_name         :text
#  birth_year              :integer
#  is_birth_year_estimated :boolean          default("true")
#  pob                     :string
#  is_pob_estimated        :boolean          default("true")
#
# Indexes
#
#  people_name_trgm  (searchable_name)
#

# frozen_string_literal: true

FactoryBot.define do
  factory(:person) do
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sex { 'M' }
    race { 'W' }
  end
end
