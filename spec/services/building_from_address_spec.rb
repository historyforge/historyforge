# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildingFromAddress do
  let(:result) { described_class.new(record).perform }

  let(:record) do
    Census1900Record.new street_house_number: '405',
                         street_prefix: 'N',
                         street_name: 'Tioga',
                         street_suffix: 'St',
                         city: 'Ithaca',
                         state: 'NY',
                         locality: build(:locality)
  end

  # gets modern address
  # gets original address
  # creates building as residence

  it 'creates building as residence' do
    expect(result.building_types.first.name).to eq('Residence')
  end

  it 'has the correct primary street address' do
    expect(result.primary_street_address).to eq('405 N Tioga St Ithaca')
  end

  it 'uses locality name in building name instead of address city' do
    locality = create(:locality, name: 'City of Ithaca', short_name: 'Ithaca')
    record.locality = locality
    building = described_class.new(record).perform
    expect(building.name).to eq('405 N Tioga St City of Ithaca')
  end
end
