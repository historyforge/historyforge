# frozen_string_literal: true

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
