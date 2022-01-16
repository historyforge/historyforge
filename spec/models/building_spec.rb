require 'rails_helper'

RSpec.describe Building do
  context 'sorting' do
    describe '#order_by_street_address' do
      let(:building_with_later_modern_address_and_earlier_antique_address) do
        build :building, addresses: [
          build(:address, is_primary: false, year: nil,  house_number: '17', name: 'Court', prefix: 'E', suffix: 'St'),
          build(:address, is_primary: false, year: 1890, house_number: '117', name: 'Court', prefix: 'E', suffix: 'St'),
          build(:address, is_primary: true,  year: 1948, house_number: '153', name: 'Court', prefix: 'E', suffix: 'St'),
        ]
      end
      let(:building_with_earlier_modern_address_and_later_antique_address) do
        build :building, addresses: [
          build(:address, is_primary: false, year: nil,  house_number: '117', name: 'Court', prefix: 'E', suffix: 'St'),
          build(:address, is_primary: false, year: 1890, house_number: '123', name: 'Court', prefix: 'E', suffix: 'St'),
          build(:address, is_primary: true,  year: 1948, house_number: '148', name: 'Court', prefix: 'E', suffix: 'St'),
        ]
      end
      before do
        building_with_later_modern_address_and_earlier_antique_address.save validate: false
        building_with_earlier_modern_address_and_later_antique_address.save validate: false
      end
      subject { Building.order_by_street_address('asc') }
      it 'puts the earliest modern address before the earliest antique address' do
        expect(subject.first).to eq(building_with_earlier_modern_address_and_later_antique_address)
        expect(subject.last).to  eq(building_with_later_modern_address_and_earlier_antique_address)
      end
    end
  end
  describe '#validate_primary_address' do
    context 'addresses managed via nested attributes' do
      before do
        subject.city = 'Ithaca'
        subject.state = 'NY'
        subject.locality = create(:locality)
      end

      it 'expects a primary address' do
        subject.addresses_attributes = [
          {
            'is_primary' => true,
            'house_number' => '110',
            'name' => 'Court',
            'prefix' => 'E',
            'suffix' => 'St'
          }
        ]
        expect(subject.save).to be_truthy
        expect(subject.addresses.size).to eq(1)
        expect(subject.errors[:base]).not_to include('Primary address missing.')
      end

      it 'errors without a primary address' do
        subject.addresses_attributes = [
          {
            'house_number' => '110',
            'name' => 'Court',
            'prefix' => 'E',
            'suffix' => 'St'
          }
        ]
        expect(subject.save).to be_falsey
        expect(subject.addresses.size).to eq(1)
        expect(subject.errors[:base]).to include('Primary address missing.')
      end

      it 'disallows multiple primary addresses' do
        subject.addresses_attributes = [
          {
            'is_primary' => true,
            'house_number' => '110',
            'name' => 'Court',
            'prefix' => 'E',
            'suffix' => 'St'
          }, {
          'is_primary' => true,
            'house_number' => '110',
            'name' => 'Mill',
            'prefix' => 'E',
            'suffix' => 'St'
          }
        ]
        subject.validate
        expect(subject.save).to be_falsey
        expect(subject.addresses.size).to eq(2)
        expect(subject.errors[:base]).to include('Multiple primary addresses not allowed.')
      end
    end
  end
end
