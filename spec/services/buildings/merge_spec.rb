# frozen_string_literal: true

require 'rails_helper'

module Buildings
  RSpec.describe Merge do
    let(:locality) { create(:locality, year_street_renumber: 1915) }
    let(:source_building) { create(:building, locality:) }
    let(:target_building) { create(:building, locality:) }
    subject { described_class.run!(source: source_building, target: target_building) }
    let(:architect) { create(:architect) }
    let(:resident) { create(:census1910_record) }
    let(:resident2) { create(:census1920_record) }
    before do
      PaperTrail.request.whodunnit = create(:user)
    end

    it 'basically works' do
      subject
      expect(source_building.destroyed?).to be_truthy
      expect(target_building.audit_logs.count).to eq(1)
    end

    it 'does not overwrite target attributes' do
      target_name = target_building.name
      subject
      expect(target_building.name).to include(target_name)
    end

    it 'transfers architects' do
      source_building.architects = [architect]
      subject
      expect(target_building.architects).to include(architect)
    end

    context 'transfers residents' do
      before { resident.update(building: source_building) }
      it 'moves the resident from the source building to the target building' do
        subject
        expect(target_building.census_1910_records).to include(resident)
      end
    end

    context 'address history' do
      before do
        resident.update(building: source_building, street_house_number: '17', street_name: 'Mill', street_prefix: 'E',
                        street_suffix: 'St', city: 'Ithaca')
        resident2.update(building: target_building, street_house_number: '117', street_name: 'Mill', street_prefix: 'E',
                         street_suffix: 'St', city: 'Ithaca')
        source_building.addresses.first.update(house_number: '17', name: 'Mill', prefix: 'E', suffix: 'St',
                                               city: 'Ithaca')
        target_building.addresses.first.update(house_number: '117', name: 'Mill', prefix: 'E', suffix: 'St',
                                               city: 'Ithaca')
        subject
      end
      it 'sets the correct year on the target address' do
        subject
        expect(target_building.address.year).to eq(locality.year_street_renumber)
        expect(target_building.addresses.length).to eq(2)
      end
    end
  end
end
