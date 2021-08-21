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

  context 'limits to 100-block' do
    context 'for 1-digit house numbers' do
      before do
        create(:building, addresses: [build(:address, house_number: '5505', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '5', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '1405', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '505', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '25', name: 'Tioga', prefix: 'N', suffix: 'St')])
      end
      let(:record) {
        Census1900Record.new street_house_number: '5',
                             street_name: 'Tioga',
                             street_prefix: 'N',
                             street_suffix: 'St' }
      it 'does not show the 5505 address' do
        expect(subject.map(&:name).detect { |name| name =~ /5505/ }).to be_falsey
      end
      it 'does not show the 505 address' do
        expect(subject.map(&:name).detect { |name| name =~ /505/ }).to be_falsey
      end
      it 'does show the 25 address' do
        expect(subject.map(&:name).detect { |name| name =~ /25\s/ }).to be_truthy
      end
    end
    context 'for 2-digit house numbers' do
      before do
        create(:building, addresses: [build(:address, house_number: '1305', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '5', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '1405', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '105', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '25', name: 'Tioga', prefix: 'N', suffix: 'St')])
      end
      let(:record) {
        Census1900Record.new street_house_number: '15',
                             street_name: 'Tioga',
                             street_prefix: 'N',
                             street_suffix: 'St' }
      it 'does not show the 1305 address' do
        expect(subject.map(&:name).detect { |name| name =~ /1305/ }).to be_falsey
      end
      it 'does show the 5 address' do
        expect(subject.map(&:name).detect { |name| name =~ /5\s/ }).to be_truthy
      end
      it 'does show the 25 address' do
        expect(subject.map(&:name).detect { |name| name =~ /25\s/ }).to be_truthy
      end
    end
    context 'for 3-digit house numbers' do
      let(:record) {
        Census1900Record.new street_house_number: '405',
                             street_name: 'Tioga',
                             street_prefix: 'N',
                             street_suffix: 'St' }
      it 'does not show the 305 address' do
        expect(subject.map(&:name).detect { |name| name =~ /305/ }).to be_falsey
      end
    end

    context 'for 4-digit house numbers' do
      before do
        create(:building, addresses: [build(:address, house_number: '1305', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '1401', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '1405', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '105', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '1405', name: 'Tioga', prefix: 'S', suffix: 'St')])
      end
      let(:record) {
        Census1900Record.new street_house_number: '1405',
                             street_name: 'Tioga',
                             street_prefix: 'N',
                             street_suffix: 'St' }
      it 'does not show the 1305 address' do
        expect(subject.map(&:name).detect { |name| name =~ /1305/ }).to be_falsey
      end
      it 'does not show the 105 address' do
        expect(subject.map(&:name).detect { |name| name =~ /105/ }).to be_falsey
      end
    end

    context 'for 5-digit house numbers' do
      before do
        create(:building, addresses: [build(:address, house_number: '1305', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '1401', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '1405', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '105', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '12406', name: 'Tioga', prefix: 'N', suffix: 'St')])
      end
      let(:record) {
        Census1900Record.new street_house_number: '12405',
                             street_name: 'Tioga',
                             street_prefix: 'N',
                             street_suffix: 'St' }
      it 'does not show the 1305 address' do
        expect(subject.map(&:name).detect { |name| name =~ /1305/ }).to be_falsey
      end
      it 'does not show the 105 address' do
        expect(subject.map(&:name).detect { |name| name =~ /105/ }).to be_falsey
      end
      it 'does not show the 12406 address' do
        expect(subject.map(&:name).detect { |name| name =~ /12406/ }).to be_truthy
      end
    end
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
      # expect(subject).to have(3).things
      expect(subject.map(&:name).all? { |name| name =~ /N Tioga/ }).to be_truthy
    end
  end

  context 'street name, suffix, and prefix' do
    let(:record) { Census1900Record.new street_name: 'Tioga', street_prefix: 'N', street_suffix: 'St' }
    it 'finds buildings on N Tioga St' do
      # expect(subject).to have(3).things
      expect(subject.map(&:name).all? { |name| name =~ /N Tioga St/ }).to be_truthy
    end
  end

  context 'full street address' do
    let(:record) { Census1900Record.new street_house_number: '405', street_name: 'Tioga', street_prefix: 'N', street_suffix: 'St' }
    it 'finds buildings on N Tioga St' do
      # expect(subject).to have(2).things
      expect(subject.map(&:name).all? { |name| name =~ /N Tioga St/ }).to be_truthy
    end
  end
end
