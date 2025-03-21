# == Schema Information
#
# Table name: buildings
#
#  id                    :integer          not null, primary key
#  name                  :string           not null
#  year_earliest         :integer
#  year_latest           :integer
#  building_type_id      :integer
#  lat                   :decimal(15, 10)
#  lon                   :decimal(15, 10)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  year_earliest_circa   :boolean          default(FALSE)
#  year_latest_circa     :boolean          default(FALSE)
#  address_house_number  :string
#  address_street_prefix :string
#  address_street_name   :string
#  address_street_suffix :string
#  stories               :float
#  annotations_legacy    :text
#  lining_type_id        :integer
#  frame_type_id         :integer
#  block_number          :string
#  created_by_id         :integer
#  reviewed_by_id        :integer
#  reviewed_at           :datetime
#  investigate           :boolean          default(FALSE)
#  investigate_reason    :string
#  notes                 :text
#  locality_id           :bigint
#  building_types_mask   :integer
#  parent_id             :bigint
#  hive_year             :integer
#
# Indexes
#
#  index_buildings_on_building_type_id  (building_type_id)
#  index_buildings_on_created_by_id     (created_by_id)
#  index_buildings_on_frame_type_id     (frame_type_id)
#  index_buildings_on_lining_type_id    (lining_type_id)
#  index_buildings_on_locality_id       (locality_id)
#  index_buildings_on_parent_id         (parent_id)
#  index_buildings_on_reviewed_by_id    (reviewed_by_id)
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Building do
  context 'with addresses' do
    let(:building) do
      create(:building, addresses: [build(:address, is_primary: true)])
    end

    it 'prevents the last address from being deleted' do
      building.addresses_attributes = [{ id: building.addresses.first.id, _destroy: true }]
      building.save
      expect(building.reload.addresses.length).to eq(1)
    end

    it 'still allows the building to be deleted' do
      building.destroy
      expect(building).to be_destroyed
    end
  end

  context 'with building types' do
    let(:building) do
      create(:building, building_type_ids: (1..8).to_a)
    end

    it 'returns the correct building type names' do
      expected_names = [
        'Cemetery',
        'Commercial',
        'Institution',
        'Marker',
        'Plantation',
        'Public',
        'Religious',
        'Residence'
      ]
      expect(building.building_types.map(&:name)).to eq expected_names
    end
  end

  context 'with scopes' do
    describe '#order_by_street_address' do
      let(:building_with_later_modern_address_and_earlier_antique_address) do
        build(:building, addresses: [
                build(:address, is_primary: false, year: nil,  house_number: '17', name: 'Court', prefix: 'E', suffix: 'St'),
                build(:address, is_primary: false, year: 1890, house_number: '117', name: 'Court', prefix: 'E', suffix: 'St'),
                build(:address, is_primary: true,  year: 1948, house_number: '153', name: 'Court', prefix: 'E', suffix: 'St'),
              ])
      end
      let(:building_with_earlier_modern_address_and_later_antique_address) do
        build(:building, addresses: [
                build(:address, is_primary: false, year: nil,  house_number: '117', name: 'Court', prefix: 'E', suffix: 'St'),
                build(:address, is_primary: false, year: 1890, house_number: '123', name: 'Court', prefix: 'E', suffix: 'St'),
                build(:address, is_primary: true,  year: 1948, house_number: '148', name: 'Court', prefix: 'E', suffix: 'St'),
              ])
      end
      let(:result) { Building.order_by_street_address('asc') }

      before do
        building_with_later_modern_address_and_earlier_antique_address.save validate: false
        building_with_earlier_modern_address_and_later_antique_address.save validate: false
      end

      it 'puts the earliest modern address before the earliest antique address' do
        expect(result.first).to eq(building_with_earlier_modern_address_and_later_antique_address)
        expect(result.last).to  eq(building_with_later_modern_address_and_earlier_antique_address)
      end
    end

    describe '#with_multiple_addresses' do
      let(:building_with_two_house_numbers_on_same_street) do
        build(:building, addresses: [
                build(:address, is_primary: false, year: nil,  house_number: '17', name: 'Tioga', prefix: 'N', suffix: 'St'),
                build(:address, is_primary: false, year: 1890, house_number: '117', name: 'Tioga', prefix: 'N', suffix: 'St'),
              ])
      end
      let(:building_with_two_addresses_on_same_street_but_same_house_number) do
        build(:building, addresses: [
                build(:address, is_primary: false, year: 1890, house_number: '705', name: 'Mill', prefix: 'E', suffix: 'St'),
                build(:address, is_primary: true,  year: 1948, house_number: '705', name: 'Court', prefix: 'E', suffix: 'St'),
              ])
      end
      let(:result) { Building.with_multiple_addresses }

      before do
        building_with_two_house_numbers_on_same_street.save validate: false
        building_with_two_addresses_on_same_street_but_same_house_number.save validate: false
      end

      it 'returns the correct building' do
        expect(result).to include(building_with_two_house_numbers_on_same_street)
        expect(result).not_to include(building_with_two_addresses_on_same_street_but_same_house_number)
      end
    end
  end

  describe '#validate_primary_address' do
    context 'with addresses managed via nested attributes' do
      before do
        subject.locality = build(:locality)
      end

      context 'when there is a primary address' do
        before do
          subject.addresses_attributes = [
            {
              'is_primary' => true,
              'house_number' => '110',
              'name' => 'Court',
              'prefix' => 'E',
              'suffix' => 'St',
              'city' => 'Ithaca'
            }
          ]
        end

        it 'expects a primary address' do
          expect(subject.save).to be_truthy
          expect(subject.addresses.size).to eq(1)
          expect(subject.errors[:base]).not_to include('Primary address missing.')
        end
      end

      context 'when there is not a primary address' do
        before do
          subject.addresses_attributes = [
            {
              'house_number' => '110',
              'name' => 'Court',
              'prefix' => 'E',
              'suffix' => 'St',
              'city' => 'Ithaca'
            }
          ]
        end

        it 'errors without a primary address' do
          expect(subject.save).to be_falsey
          expect(subject.addresses.size).to eq(1)
          expect(subject.errors[:base]).to include('Primary address missing.')
        end
      end

      context 'with multiple primary addresses' do
        before do
          subject.addresses_attributes = [
            {
              'is_primary' => true,
              'house_number' => '110',
              'name' => 'Court',
              'prefix' => 'E',
              'suffix' => 'St',
              'city' => 'Ithaca'
            }, {
              'is_primary' => true,
              'house_number' => '110',
              'name' => 'Mill',
              'prefix' => 'E',
              'suffix' => 'St',
              'city' => 'Ithaca'
            }
          ]
          subject.validate
        end
        it 'disallows multiple primary addresses' do
          expect(subject.save).to be_falsey
          expect(subject.addresses.size).to eq(2)
          expect(subject.errors[:base]).to include('Multiple primary addresses not allowed.')
        end
      end
    end
  end
end
