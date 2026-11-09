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
    building = described_class.new(record).perform
    expect(building.name).to eq("405 N Tioga St #{record.locality.name}")
  end

  it 'reuses the matching street address in the census locality even when Place differs' do
    record.locality = create(:locality)
    record.city = 'Forest Home'
    street = { house_number: '405', prefix: 'N', name: 'Tioga', suffix: 'St' }
    create(:building, addresses: [build(:address, **street, city: 'Forest Home')])
    existing = create(:building, locality: record.locality, addresses: [build(:address, **street, city: nil)])

    expect { expect(result).to eq(existing) }.not_to change(Building, :count)
    expect(existing.reload.address.city).to be_nil
  end

  it 'creates a building from a census record without a Place' do
    record.city = nil

    expect(result).to be_persisted
    expect(result.address.city).to be_nil
    expect(result.full_street_address).to include(record.locality.name)
  end
end
