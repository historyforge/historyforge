# frozen_string_literal: true

require 'rails_helper'

module Buildings
  RSpec.describe Merge do
    let(:locality) { create(:locality, year_street_renumber: 1915) }
    let(:source) { create(:building, locality:) }
    let(:target) { create(:building, locality:) }
    subject { described_class.run!(source:, target:) }
    let(:architect) { create(:architect) }
    let(:resident) { create(:census1910_record) }
    let(:resident2) { create(:census1920_record) }
    before do
      PaperTrail.request.whodunnit = create(:user)
    end

    it 'basically works' do
      subject
      expect(source.destroyed?).to be_truthy
      expect(target.audit_logs.count).to eq(1)
    end

    it 'does not overwrite target attributes' do
      target_name = target.name
      subject
      expect(target.name).to include(target_name)
    end

    it 'transfers architects' do
      source.architects = [architect]
      subject
      expect(target.architects).to include(architect)
    end

    context 'transfers residents' do
      before { resident.update(building: source) }
      it 'moves the resident from the source building to the target building' do
        subject
        expect(target.census_1910_records).to include(resident)
      end
    end

    context 'address history' do
      before do
        resident.update(building: source, street_house_number: '17', street_name: 'Mill', street_prefix: 'E',
                        street_suffix: 'St', city: 'Ithaca')
        resident2.update(building: target, street_house_number: '117', street_name: 'Mill', street_prefix: 'E',
                         street_suffix: 'St', city: 'Ithaca')
        source.addresses.first.update(house_number: '17', name: 'Mill', prefix: 'E', suffix: 'St',
                                      city: 'Ithaca')
        target.addresses.first.update(house_number: '117', name: 'Mill', prefix: 'E', suffix: 'St',
                                      city: 'Ithaca')
        subject
      end
      it 'sets the correct year on the target address' do
        subject
        expect(target.address.year).to eq(locality.year_street_renumber)
        expect(target.addresses.length).to eq(2)
      end
    end
  end
end
