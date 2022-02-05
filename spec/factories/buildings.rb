# == Schema Information
#
# Table name: buildings
#
#  id                    :integer          not null, primary key
#  name                  :string           not null
#  city                  :string           not null
#  state                 :string           not null
#  postal_code           :string
#  year_earliest         :integer
#  year_latest           :integer
#  building_type_id      :integer
#  description           :text
#  lat                   :decimal(15, 10)
#  lon                   :decimal(15, 10)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  year_earliest_circa   :boolean          default("false")
#  year_latest_circa     :boolean          default("false")
#  address_house_number  :string
#  address_street_prefix :string
#  address_street_name   :string
#  address_street_suffix :string
#  stories               :float
#  annotations_legacy    :text
#  lining_type_id        :integer
#  frame_type_id         :integer
#  block_number          :string
#  created_by_id         :integer
#  reviewed_by_id        :integer
#  reviewed_at           :datetime
#  investigate           :boolean          default("false")
#  investigate_reason    :string
#  notes                 :text
#  locality_id           :integer
#  building_types_mask   :integer
#
# Indexes
#
#  index_buildings_on_building_type_id  (building_type_id)
#  index_buildings_on_created_by_id     (created_by_id)
#  index_buildings_on_frame_type_id     (frame_type_id)
#  index_buildings_on_lining_type_id    (lining_type_id)
#  index_buildings_on_locality_id       (locality_id)
#  index_buildings_on_reviewed_by_id    (reviewed_by_id)
#

# frozen_string_literal: true

FactoryBot.define do
  factory(:building) do
    addresses { [build(:address, is_primary: true)] }
    name { "The #{Faker::Name.name} Building" }
    city { 'Ithaca' }
    state { 'New York' }
    lat { 42.442376 }
    lon { -76.4907835 }
    locality { Locality.find_or_create_by(name: 'Town of There') }
    building_type_ids { [1] }
    frame_type_id { 1 }
    lining_type_id { 1 }
    architects { [Architect.find_or_create_by(name: 'William Henry Miller')] }
    year_earliest { 1840 }
    year_latest { 1930 }
    stories { 1 }

    trait :reviewed do
      reviewed_at { 1.day.ago }
      # don't care about reviewed_by for now...
    end
  end
end
