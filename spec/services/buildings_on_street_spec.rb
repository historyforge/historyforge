# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildingsOnStreet do
  subject { BuildingsOnStreet.new(record).perform }
  let(:locality) { create(:locality) }
  before do
    create(:building, locality:, addresses: [build(:address, house_number: '305', name: 'Tioga', prefix: 'N', suffix: 'St')])
    create(:building, locality:, addresses: [build(:address, house_number: '401', name: 'Tioga', prefix: 'N', suffix: 'St')])
    create(:building, locality:, addresses: [build(:address, house_number: '405', name: 'Tioga', prefix: 'N', suffix: 'St')])
    create(:building, locality:, addresses: [build(:address, house_number: '405', name: 'Titus', prefix: 'N', suffix: 'Ave')])
    create(:building, locality:, addresses: [build(:address, house_number: '405', name: 'Tioga', prefix: 'S', suffix: 'St')])
    create(:building, locality:, addresses: [build(:address, house_number: '405', name: 'Cayuga', prefix: 'N', suffix: 'St')])
  end

  context 'with duplicates' do
    before do
      create(:building, locality:, addresses: [
        build(:address, house_number: '306', name: 'Tioga', prefix: 'N', suffix: 'St', is_primary: true),
        build(:address, house_number: '307', name: 'Tioga', prefix: 'N', suffix: 'St', is_primary: false)
      ])

    end
    let(:record) do
      Census1900Record.new locality:,
                           street_house_number: '305',
                           street_name: 'Tioga',
                           street_prefix: 'N',
                           street_suffix: 'St' end
    it 'ignores duplicates' do
      ids = subject.map(&:id)
      expect(ids.length).to eq(ids.uniq.length)
    end
  end
  context 'limits to 100-block' do
    context 'for 1-digit house numbers' do
      before do
        create(:building, locality:, addresses: [build(:address, house_number: '5505', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '5', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '1405', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '505', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '25', name: 'Tioga', prefix: 'N', suffix: 'St')])
      end
      let(:record) do
        Census1900Record.new locality:,
                             street_house_number: '5',
                             street_name: 'Tioga',
                             street_prefix: 'N',
                             street_suffix: 'St' end
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
        create(:building, locality:, addresses: [build(:address, house_number: '1305', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '5', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '1405', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '105', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '25', name: 'Tioga', prefix: 'N', suffix: 'St')])
      end
      let(:record) do
        Census1900Record.new locality:,
                             street_house_number: '15',
                             street_name: 'Tioga',
                             street_prefix: 'N',
                             street_suffix: 'St' end
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
      let(:record) do
        Census1900Record.new locality:,
                             street_house_number: '405',
                             street_name: 'Tioga',
                             street_prefix: 'N',
                             street_suffix: 'St' end
      it 'does not show the 305 address' do
        expect(subject.map(&:name).detect { |name| name =~ /305/ }).to be_falsey
      end
      context 'with a hyphenated house number' do
        before do
          create(:building, locality:, addresses: [build(:address, house_number: '405-407', name: 'Tioga', prefix: 'N', suffix: 'St')])
        end
        it 'shows the hyphenated address' do
          expect(subject.map(&:name).detect { |name| name =~ /405\-407/ }).to be_truthy
        end
      end
    end

    context 'for 4-digit house numbers' do
      before do
        create(:building, locality:, addresses: [build(:address, house_number: '1305', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '1401', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '1405', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '105', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '1405', name: 'Tioga', prefix: 'S', suffix: 'St')])
      end
      let(:record) do
        Census1900Record.new locality:,
                             street_house_number: '1405',
                             street_name: 'Tioga',
                             street_prefix: 'N',
                             street_suffix: 'St' end
      it 'does show the 1405 address' do
        expect(subject.map(&:name).detect { |name| name =~ /1405/ }).to be_truthy
      end
      it 'does not show the 1305 address' do
        expect(subject.map(&:name).detect { |name| name =~ /1305/ }).to be_falsey
      end
      it 'does not show the 105 address' do
        expect(subject.map(&:name).detect { |name| name =~ /105/ }).to be_falsey
      end
    end

    context 'for 5-digit house numbers' do
      before do
        create(:building, locality:, addresses: [build(:address, house_number: '1305', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '1401', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '1405', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '105', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, locality:, addresses: [build(:address, house_number: '12406', name: 'Tioga', prefix: 'N', suffix: 'St')])
      end
      let(:record) do
        Census1900Record.new locality:,
                             street_house_number: '12405',
                             street_name: 'Tioga',
                             street_prefix: 'N',
                             street_suffix: 'St' end
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
    let(:building) { create(:building, locality:, addresses: [address]) }
    let(:record) do
      Census1900Record.new locality:,
                           building_id: building.id,
                           street_house_number: '405',
                           street_name: 'Tioga',
                           street_prefix: 'N',
                           street_suffix: 'St' end
    it 'still puts the building in the list even though it is not on the street being searched' do
      expect(subject.map(&:id)).to include(building.id)
    end
  end

  context 'street name and house number' do
    let(:record) { Census1900Record.new locality:, street_house_number: '405', street_name: 'Tioga' }
    it 'returns 405 N and S Tioga' do
      names = subject.map(&:name)
      expect(names.detect { |name| name =~ /405 N Tioga St/ }).to be_truthy
      expect(names.detect { |name| name =~ /405 S Tioga St/ }).to be_truthy
    end
    context 'with hyphenated house number' do
      before do
        create(:building, locality:, addresses: [build(:address, house_number: '405-407', name: 'Tioga', prefix: 'N', suffix: 'St')])
      end
      it 'finds the hyphenated address' do
        expect(subject.map(&:name).detect { |name| name =~ /405-407/ }).to be_truthy
      end
    end
    context 'with exact hundred block' do
      let(:record) { Census1900Record.new locality:, street_house_number: '400', street_name: 'Tioga' }
      before do
        create(:building, locality:, addresses: [build(:address, house_number: '400', name: 'Tioga', prefix: 'N', suffix: 'St')])
      end
      it 'finds the hyphenated address' do
        expect(subject.map(&:name).detect { |name| name =~ /400 N Tioga/ }).to be_truthy
      end
    end
  end

  context 'street name only' do
    let(:record) { Census1900Record.new locality:, street_name: 'Tioga' }
    it 'finds buildings on Tioga' do
      expect(subject).to have(4).things
      expect(subject.map(&:name).all? { |name| name =~ /Tioga/ }).to be_truthy
    end
  end

  context 'street name and suffix' do
    let(:record) { Census1900Record.new locality:, street_name: 'Tioga', street_suffix: 'St' }
    it 'finds buildings on Tioga St' do
      expect(subject).to have(4).things
      expect(subject.map(&:name).all? { |name| name =~ /Tioga St/ }).to be_truthy
    end
  end

  context 'street name and prefix' do
    let(:record) { Census1900Record.new locality:, street_name: 'Tioga', street_prefix: 'N' }
    it 'finds buildings on N Tioga' do
      expect(subject.map(&:name).all? { |name| name =~ /N Tioga/ }).to be_truthy
    end
  end

  context 'street name, suffix, and prefix' do
    let(:record) { Census1900Record.new locality:, street_name: 'Tioga', street_prefix: 'N', street_suffix: 'St' }
    it 'finds buildings on N Tioga St' do
      expect(subject.map(&:name).all? { |name| name =~ /N Tioga St/ }).to be_truthy
    end
  end

  context 'full street address' do
    let(:record) { Census1900Record.new locality:, street_house_number: '405', street_name: 'Tioga', street_prefix: 'N', street_suffix: 'St' }
    it 'finds buildings on N Tioga St' do
      expect(subject.map(&:name).all? { |name| name =~ /N Tioga St/ }).to be_truthy
    end
  end
end
