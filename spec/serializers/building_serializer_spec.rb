# frozen_string_literal: true

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
#  year_earliest_circa   :boolean          default(FALSE)
#  year_latest_circa     :boolean          default(FALSE)
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
#  investigate           :boolean          default(FALSE)
#  investigate_reason    :string
#  notes                 :text
#  locality_id           :bigint
#  building_types_mask   :integer
#  parent_id             :bigint
#  hive_year             :integer
#
# Indexes
#
#  index_buildings_on_building_type_id  (building_type_id)
#  index_buildings_on_created_by_id     (created_by_id)
#  index_buildings_on_frame_type_id     (frame_type_id)
#  index_buildings_on_lining_type_id    (lining_type_id)
#  index_buildings_on_locality_id       (locality_id)
#  index_buildings_on_parent_id         (parent_id)
#  index_buildings_on_reviewed_by_id    (reviewed_by_id)
#
require 'rails_helper'

RSpec.describe BuildingSerializer do
  let(:building) { create(:building).decorate }
  subject { BuildingSerializer.new(building).as_json }

  it 'has the correct fields' do
    expect(subject['id']).to eq(building.id)
    expect(subject['frame']).to eq(building.frame)
    expect(subject['lining']).to eq(building.lining)
    expect(subject['building_type_ids']).to eq(building.building_type_ids)
    expect(subject['type']).to eq(building.type)
    expect(subject['stories']).to eq(building.stories)
    expect(subject['year_earliest']).to eq(building.year_earliest)
    expect(subject['year_latest']).to eq(building.year_latest)
    expect(subject['street_address']).to eq(building.street_address)

    expect(subject['architects']).to eq(building.architects)
  end
end
