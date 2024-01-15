# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NextCensusRecordAttributes do
  let(:result) { described_class.new(record, action) }

  let(:record) { Census1900Record.new }

  describe 'attributes' do
    before do
      record.page_number = 1
      record.page_side = 'A'
      record.line_number = 1
      record.county = 'Tompkins'
      record.city = 'Ithaca'
      record.ward = 1
      record.enum_dist = 172
      record.locality_id = 1
      record.dwelling_number = 1
      record.family_id = 1
      record.street_house_number = '405'
      record.street_prefix = 'N'
      record.street_name = 'Tioga'
      record.street_suffix = 'St'
      record.building_id = 1
    end

    context 'with same enumeration district' do
      let(:action) { 'enumeration' }

      it 'has the correct attributes' do
        expect(result.attributes[:county]).to eq(record.county)
        expect(result.attributes[:city]).to eq(record.city)
        expect(result.attributes[:ward]).to eq(record.ward)
        expect(result.attributes[:enum_dist]).to eq(record.enum_dist)
        expect(result.attributes[:locality_id]).to eq(record.locality_id)
        %i[dwelling_number family_id street_house_number
           street_prefix street_name street_suffix building_id].each do |attribute|
          expect(result.attributes[attribute]).to be_nil
        end
      end
    end

    context 'with the same street' do
      let(:action) { 'street' }

      it 'has the correct attributes' do
        expect(result.attributes[:county]).to eq(record.county)
        expect(result.attributes[:city]).to eq(record.city)
        expect(result.attributes[:ward]).to eq(record.ward)
        expect(result.attributes[:enum_dist]).to eq(record.enum_dist)
        expect(result.attributes[:locality_id]).to eq(record.locality_id)
        expect(result.attributes[:street_prefix]).to eq(record.street_prefix)
        expect(result.attributes[:street_name]).to eq(record.street_name)
        expect(result.attributes[:street_suffix]).to eq(record.street_suffix)
        %i[dwelling_number family_id street_house_number building_id].each do |attribute|
          expect(result.attributes[attribute]).to be_nil
        end
      end
    end

    context 'with the same dwelling' do
      let(:action) { 'dwelling' }

      it 'has the correct attributes' do
        expect(result.attributes[:county]).to eq(record.county)
        expect(result.attributes[:city]).to eq(record.city)
        expect(result.attributes[:ward]).to eq(record.ward)
        expect(result.attributes[:enum_dist]).to eq(record.enum_dist)
        expect(result.attributes[:locality_id]).to eq(record.locality_id)
        expect(result.attributes[:dwelling_number]).to eq(record.dwelling_number)
        expect(result.attributes[:family_id]).to be_nil
        expect(result.attributes[:street_house_number]).to eq(record.street_house_number)
        expect(result.attributes[:street_prefix]).to eq(record.street_prefix)
        expect(result.attributes[:street_name]).to eq(record.street_name)
        expect(result.attributes[:street_suffix]).to eq(record.street_suffix)
        expect(result.attributes[:building_id]).to eq(record.building_id)
      end
    end

    context 'with same family' do
      let(:action) { 'family' }

      it 'has the correct attributes' do
        expect(result.attributes[:county]).to eq(record.county)
        expect(result.attributes[:city]).to eq(record.city)
        expect(result.attributes[:ward]).to eq(record.ward)
        expect(result.attributes[:enum_dist]).to eq(record.enum_dist)
        expect(result.attributes[:locality_id]).to eq(record.locality_id)
        expect(result.attributes[:dwelling_number]).to eq(record.dwelling_number)
        expect(result.attributes[:family_id]).to eq(record.family_id)
        expect(result.attributes[:street_house_number]).to eq(record.street_house_number)
        expect(result.attributes[:street_prefix]).to eq(record.street_prefix)
        expect(result.attributes[:street_name]).to eq(record.street_name)
        expect(result.attributes[:street_suffix]).to eq(record.street_suffix)
        expect(result.attributes[:building_id]).to eq(record.building_id)
      end
    end
  end

  describe 'pagination' do
    let(:action) { 'enumeration' }

    context 'when not at the end of page or side' do
      before do
        record.page_number = 1
        record.page_side = 'A'
        record.line_number = 1
      end

      it 'goes to the next line' do
        expect(result.attributes[:page_number]).to eq(1)
        expect(result.attributes[:page_side]).to eq('A')
        expect(result.attributes[:line_number]).to eq(2)
      end
    end

    context 'when at the end of side A' do
      before do
        record.page_number = 1
        record.page_side = 'A'
        record.line_number = record.per_page
      end

      it 'goes to the first line of side B' do
        expect(result.attributes[:page_number]).to eq(1)
        expect(result.attributes[:page_side]).to eq('B')
        expect(result.attributes[:line_number]).to eq(1)
      end
    end

    context 'when at the end of side B' do
      before do
        record.page_number = 1
        record.page_side = 'B'
        record.line_number = record.per_page
      end

      it 'goes to the first line of side A of next page' do
        expect(result.attributes[:page_number]).to eq(2)
        expect(result.attributes[:page_side]).to eq('A')
        expect(result.attributes[:line_number]).to eq(1)
      end
    end
  end
end
