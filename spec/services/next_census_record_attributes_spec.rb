# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NextCensusRecordAttributes do
  shared_examples 'common record setup' do
    before do
      record.page_number = 1
      record.page_side = 'A'
      record.line_number = 1
      record.county = 'Tompkins'
      record.city = 'Ithaca'
      record.ward = 1
      record.enum_dist = 172 if record.respond_to?(:enum_dist=)
      record.locality_id = 1
      record.dwelling_number = 1
      record.family_id = 1
      record.street_house_number = '405'
      record.street_prefix = 'N'
      record.street_name = 'Tioga'
      record.street_suffix = 'St'
      record.building_id = 1
    end
  end

  describe 'attributes' do
    context 'with same enumeration district' do
      let(:record) { Census1900Record.new }
      let(:action) { 'enumeration' }
      let(:result) { described_class.call(record, action) }

      include_examples 'common record setup'

      it 'has the correct attributes' do
        expect(result[:county]).to eq(record.county)
        expect(result[:city]).to eq(record.city)
        expect(result[:ward]).to eq(record.ward)
        expect(result[:enum_dist]).to eq(record.enum_dist)
        expect(result[:locality_id]).to eq(record.locality_id)
        %i[dwelling_number family_id street_house_number
           street_prefix street_name street_suffix building_id].each do |attribute|
          expect(result[attribute]).to be_nil
        end
      end
    end

    context 'with the same street' do
      let(:record) { Census1900Record.new }
      let(:action) { 'street' }
      let(:result) { described_class.call(record, action) }

      include_examples 'common record setup'

      it 'has the correct attributes' do
        expect(result[:county]).to eq(record.county)
        expect(result[:city]).to eq(record.city)
        expect(result[:ward]).to eq(record.ward)
        expect(result[:enum_dist]).to eq(record.enum_dist)
        expect(result[:locality_id]).to eq(record.locality_id)
        expect(result[:street_prefix]).to eq(record.street_prefix)
        expect(result[:street_name]).to eq(record.street_name)
        expect(result[:street_suffix]).to eq(record.street_suffix)
        %i[dwelling_number family_id street_house_number building_id].each do |attribute|
          expect(result[attribute]).to be_nil
        end
      end
    end

    context 'with the same dwelling' do
      let(:record) { Census1900Record.new }
      let(:action) { 'dwelling' }
      let(:result) { described_class.call(record, action) }

      include_examples 'common record setup'

      it 'has the correct attributes' do
        expect(result[:county]).to eq(record.county)
        expect(result[:city]).to eq(record.city)
        expect(result[:ward]).to eq(record.ward)
        expect(result[:enum_dist]).to eq(record.enum_dist)
        expect(result[:locality_id]).to eq(record.locality_id)
        expect(result[:dwelling_number]).to eq(record.dwelling_number)
        expect(result[:family_id]).to be_nil
        expect(result[:street_house_number]).to eq(record.street_house_number)
        expect(result[:street_prefix]).to eq(record.street_prefix)
        expect(result[:street_name]).to eq(record.street_name)
        expect(result[:street_suffix]).to eq(record.street_suffix)
        expect(result[:building_id]).to eq(record.building_id)
      end
    end

    context 'with same family' do
      context 'for censuses with institution field (1870-1940)' do
        let(:record) { Census1900Record.new }
        let(:action) { 'family' }
        let(:result) { described_class.call(record, action) }

        include_examples 'common record setup'

        before do
          record.institution = 'State Hospital'
        end

        it 'copies institution field and excludes institution_type/institution_name' do
          expect(result[:county]).to eq(record.county)
          expect(result[:city]).to eq(record.city)
          expect(result[:ward]).to eq(record.ward)
          expect(result[:enum_dist]).to eq(record.enum_dist)
          expect(result[:locality_id]).to eq(record.locality_id)
          expect(result[:dwelling_number]).to eq(record.dwelling_number)
          expect(result[:family_id]).to eq(record.family_id)
          expect(result[:street_house_number]).to eq(record.street_house_number)
          expect(result[:street_prefix]).to eq(record.street_prefix)
          expect(result[:street_name]).to eq(record.street_name)
          expect(result[:street_suffix]).to eq(record.street_suffix)
          expect(result[:building_id]).to eq(record.building_id)
          expect(result[:institution]).to eq(record.institution)
          expect(result[:institution_type]).to be_nil
          expect(result[:institution_name]).to be_nil
        end
      end

      context 'for censuses with institution_type and institution_name (1850, 1860, 1950)' do
        let(:record) { Census1860Record.new }
        let(:action) { 'family' }
        let(:result) { described_class.call(record, action) }

        include_examples 'common record setup'

        before do
          record.institution_type = 'Prison'
          record.institution_name = 'Auburn State Prison'
        end

        it 'copies institution_type and institution_name fields and excludes institution' do
          expect(result[:county]).to eq(record.county)
          expect(result[:city]).to eq(record.city)
          expect(result[:ward]).to eq(record.ward)
          expect(result[:enum_dist]).to eq(record.enum_dist) if record.respond_to?(:enum_dist)
          expect(result[:locality_id]).to eq(record.locality_id)
          expect(result[:dwelling_number]).to eq(record.dwelling_number)
          expect(result[:family_id]).to eq(record.family_id)
          expect(result[:street_house_number]).to eq(record.street_house_number)
          expect(result[:street_prefix]).to eq(record.street_prefix)
          expect(result[:street_name]).to eq(record.street_name)
          expect(result[:street_suffix]).to eq(record.street_suffix)
          expect(result[:building_id]).to eq(record.building_id)
          expect(result[:institution_type]).to eq(record.institution_type)
          expect(result[:institution_name]).to eq(record.institution_name)
          expect(result[:institution]).to be_nil
        end
      end

      context 'for 1950 census (also has institution_type and institution_name)' do
        let(:record) { Census1950Record.new }
        let(:action) { 'family' }
        let(:result) { described_class.call(record, action) }

        include_examples 'common record setup'

        before do
          record.institution_type = 'Hospital'
          record.institution_name = 'General Hospital'
        end

        it 'copies institution_type and institution_name fields' do
          expect(result[:institution_type]).to eq(record.institution_type)
          expect(result[:institution_name]).to eq(record.institution_name)
          expect(result[:institution]).to be_nil
        end
      end
    end
  end

  describe 'pagination' do
    let(:record) { Census1900Record.new }
    let(:action) { 'enumeration' }

    context 'when not at the end of page or side' do
      before do
        record.page_number = 1
        record.page_side = 'A'
        record.line_number = 1
      end

      it 'goes to the next line' do
        result = described_class.call(record, action)
        expect(result[:page_number]).to eq(1)
        expect(result[:page_side]).to eq('A')
        expect(result[:line_number]).to eq(2)
      end
    end

    context 'when at the end of side A' do
      before do
        record.page_number = 1
        record.page_side = 'A'
        record.line_number = record.per_page
      end

      it 'goes to the first line of side B' do
        result = described_class.call(record, action)
        expect(result[:page_number]).to eq(1)
        expect(result[:page_side]).to eq('B')
        expect(result[:line_number]).to eq(1)
      end
    end

    context 'when at the end of side B' do
      before do
        record.page_number = 1
        record.page_side = 'B'
        record.line_number = record.per_page
      end

      it 'goes to the first line of side A of next page' do
        result = described_class.call(record, action)
        expect(result[:page_number]).to eq(2)
        expect(result[:page_side]).to eq('A')
        expect(result[:line_number]).to eq(1)
      end
    end
  end
end
