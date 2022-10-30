# == Schema Information
#
# Table name: addresses
#
#  id           :bigint           not null, primary key
#  building_id  :bigint           not null
#  is_primary   :boolean          default(FALSE)
#  house_number :string
#  prefix       :string
#  name         :string
#  suffix       :string
#  city         :string
#  postal_code  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  year         :integer
#
# Indexes
#
#  index_addresses_on_building_id  (building_id)
#

# frozen_string_literal: true

FactoryBot.define do
  factory(:address) do
    is_primary { true }
    house_number { rand(500) }
    name { Faker::Name.name }
    prefix { ([nil] + %w[N E W S])[rand(0..4)] }
    suffix { ([nil] + %w[St Pl Rd Blvd Ave])[rand(0..5)] }
    city { 'Ithaca' }
  end
end
