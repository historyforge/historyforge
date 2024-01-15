# frozen_string_literal: true

# == Schema Information
#
# Table name: buildings
#
#  id                    :integer          not null, primary key
#  name                  :string           not null
#  year_earliest         :integer
#  year_latest           :integer
#  building_type_id      :integer
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
  let(:result) { described_class.new(building).as_json }
  let(:building) { create(:building).decorate }

  it 'has the correct fields' do
    expect(result['id']).to eq(building.id)
    expect(result['frame']).to eq(building.frame)
    expect(result['lining']).to eq(building.lining)
    expect(result['building_type_ids']).to eq(building.building_type_ids)
    expect(result['type']).to eq(building.type)
    expect(result['stories']).to eq(building.stories)
    expect(result['year_earliest']).to eq(building.year_earliest)
    expect(result['year_latest']).to eq(building.year_latest)
    expect(result['street_address']).to eq(building.street_address)
    expect(result['architects']).to eq(building.architects)
  end
end
