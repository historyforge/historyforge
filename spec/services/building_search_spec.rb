# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildingSearch do
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
