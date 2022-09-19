# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildingFromAddress do
  subject { described_class.new(record).perform }
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
    expect(subject.building_types.first.name).to eq('Residence')
  end

  it 'has the correct primary street address' do
    expect(subject.primary_street_address).to eq('405 N Tioga St Ithaca')
  end
end
