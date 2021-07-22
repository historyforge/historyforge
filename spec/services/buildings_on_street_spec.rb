# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildingsOnStreet do
  subject { BuildingsOnStreet.new(record).perform }
  before do
    create(:building, addresses: [build(:address, house_number: '305', name: 'Tioga', prefix: 'N', suffix: 'St')])
    create(:building, addresses: [build(:address, house_number: '401', name: 'Tioga', prefix: 'N', suffix: 'St')])
    create(:building, addresses: [build(:address, house_number: '405', name: 'Tioga', prefix: 'N', suffix: 'St')])
    create(:building, addresses: [build(:address, house_number: '405', name: 'Titus', prefix: 'N', suffix: 'Ave')])
    create(:building, addresses: [build(:address, house_number: '405', name: 'Tioga', prefix: 'S', suffix: 'St')])
    create(:building, addresses: [build(:address, house_number: '405', name: 'Cayuga', prefix: 'N', suffix: 'St')])
  end

  context 'with building_id' do
    let(:address) { build(:address, house_number: '407', name: 'Cayuga', prefix: 'N', suffix: 'St') }
    let(:building) { create(:building, addresses: [address]) }
    let(:record) {
      Census1900Record.new building_id: building.id,
                           street_house_number: '405',
                           street_name: 'Tioga',
                           street_prefix: 'N',
                           street_suffix: 'St' }
    it 'still puts the building at the top of the list even though it is not on the street being searched' do
      expect(subject.first.id).to eq(building.id)
    end
  end

  context 'street name only' do
    let(:record) { Census1900Record.new street_name: 'Tioga' }
    it 'finds buildings on Tioga' do
      expect(subject).to have(4).things
      expect(subject.map(&:name).all? { |name| name =~ /Tioga/ }).to be_truthy
    end
  end

  context 'street name and suffix' do
    let(:record) { Census1900Record.new street_name: 'Tioga', street_suffix: 'St' }
    it 'finds buildings on Tioga St' do
      expect(subject).to have(4).things
      expect(subject.map(&:name).all? { |name| name =~ /Tioga St/ }).to be_truthy
    end
  end

  context 'street name and prefix' do
    let(:record) { Census1900Record.new street_name: 'Tioga', street_prefix: 'N' }
    it 'finds buildings on N Tioga' do
      expect(subject).to have(3).things
      expect(subject.map(&:name).all? { |name| name =~ /N Tioga/ }).to be_truthy
    end
  end

  context 'street name, suffix, and prefix' do
    let(:record) { Census1900Record.new street_name: 'Tioga', street_prefix: 'N', street_suffix: 'St' }
    it 'finds buildings on N Tioga St' do
      expect(subject).to have(3).things
      expect(subject.map(&:name).all? { |name| name =~ /N Tioga St/ }).to be_truthy
    end
  end

  context 'full street address' do
    let(:record) { Census1900Record.new street_house_number: '405', street_name: 'Tioga', street_prefix: 'N', street_suffix: 'St' }
    it 'finds buildings on N Tioga St' do
      expect(subject).to have(2).things
      expect(subject.map(&:name).all? { |name| name =~ /N Tioga St/ }).to be_truthy
    end
  end
end
