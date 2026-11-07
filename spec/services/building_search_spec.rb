# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildingSearch do
  it 'filters by the building creator and reserves direct creator predicates' do
    creator = create(:census_taker)
    own_building = create(:building, created_by: creator)
    other_building = create(:building, created_by: create(:active_user))

    search = described_class.generate(user: creator, creator_scope: creator.id, params: { s: { creator_id: creator.id } })
    expect(search).to be_active
    expect(search.scoped).to contain_exactly(own_building)

    bypass = described_class.generate(user: creator, params: { s: { created_by_id_eq: other_building.created_by_id } })
    expect(bypass.scoped).to contain_exactly(own_building, other_building)
  end

  context 'when near argument is passed' do
    it 'applies a distance query' do
      building1 = create(:building, lat: -42.50002, lon: 71.20003)
      building2 = create(:building, lat: -42.50002, lon: 71.20002)
      building3 = create(:building, lat: -42.50001, lon: 71.20001)
      search = described_class.new(near: '-42.5+71.2', user: create(:active_user))
      expect(search.results.length).to eq 3
      expect(search.results.map(&:id)).to contain_exactly(building3.id, building2.id, building1.id)
    end
  end
end
