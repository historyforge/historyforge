# frozen_string_literal: true

require 'rails_helper'

module Buildings
  RSpec.describe Merge do
    let(:locality) { create(:locality, year_street_renumber: 1915) }
    let(:source) { create(:building, locality:) }
    let(:target) { create(:building, locality:) }

    before do
      PaperTrail.request.whodunnit = create(:user)
    end

    def run_interaction
      described_class.call(source:, target:)
    end

    context 'with the basic case' do
      it 'basically works' do
        target_name = target.name
        run_interaction
        expect(target.name).to include(target_name)
        expect(source).to be_destroyed
        expect(target.audit_logs.count).to eq(1)
      end
    end

    context 'with architects' do
      let(:architect) { create(:architect) }

      before do
        source.architects = [architect]
        run_interaction
      end

      it 'transfers architects' do
        expect(target.architects).to include(architect)
      end
    end

    context 'with residents' do
      let(:resident) { create(:census1910_record) }

      before do
        resident.update(building: source)
        run_interaction
      end

      it 'moves the resident from the source building to the target building' do
        expect(target.census1910_records).to include(resident)
      end
    end

    context 'with address history' do
      let(:resident) { create(:census1910_record) }
      let(:resident2) { create(:census1920_record) }

      before do
        resident.update(building: source, street_house_number: '17', street_name: 'Mill', street_prefix: 'E',
                        street_suffix: 'St', city: 'Ithaca')
        resident2.update(building: target, street_house_number: '117', street_name: 'Mill', street_prefix: 'E',
                         street_suffix: 'St', city: 'Ithaca')
        source.addresses.first.update(house_number: '17', name: 'Mill', prefix: 'E', suffix: 'St',
                                      city: 'Ithaca')
        target.addresses.first.update(house_number: '117', name: 'Mill', prefix: 'E', suffix: 'St',
                                      city: 'Ithaca')
        run_interaction
      end

      it 'sets the correct year on the target address' do
        expect(target.address.year).to eq(locality.year_street_renumber)
        expect(target.addresses.length).to eq(2)
      end
    end
  end
end
