require 'rails_helper'

RSpec.describe Building do
  describe '#validate_primary_address' do
    context 'addresses managed via nested attributes' do
      before do
        subject.city = 'Ithaca'
        subject.state = 'NY'
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