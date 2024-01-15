# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttributeAutocomplete do
  let(:result) { described_class.new(attribute:, term:, year:).perform }

  let(:year) { 1900 }

  context 'with attributes' do
    describe 'an existing attribute' do
      let(:attribute) { 'occupation' }
      let(:term) { 'Ba' }

      before do
        create(:census1900_record, occupation: 'Barber')
        create(:census1900_record, occupation: 'Baker')
      end

      it 'finds the barber and the baker' do
        expect(result).to include('Barber')
        expect(result).to include('Baker')
      end
    end

    describe 'a non-existent attribute' do
      let(:attribute) { 'attitude' }
      let(:term) { 'happy' }

      it { expect(result).to be_empty }
    end
  end

  context 'with controlled vocabularies' do
    describe 'relation_to_head' do
      let(:attribute) { 'relation_to_head' }
      let(:term) { 'Ado' }

      it 'finds terms that start with Adopted' do
        expect(result).to include('Adopted Brother')
        expect(result).to include('Adopted Sister')
      end
    end

    describe 'pob' do
      let(:attribute) { 'pob' }
      let(:term) { 'Ger' }

      it 'finds terms that start with Germany' do
        expect(result).to include('Germany')
      end
    end

    describe 'language_spoken' do
      let(:attribute) { 'language_spoken' }
      let(:term) { 'Ger' }

      it 'finds terms that start with Ger' do
        expect(result).to include('German')
      end
    end
  end

  context 'with name fields' do
    describe 'first_name' do
      let(:attribute) { 'first_name' }
      let(:term) { 'Da' }

      before do
        create(:person, first_name: 'David')
        create(:person, first_name: 'Daniel')
        create(:person, first_name: 'Darrell')
        create(:person, first_name: 'Terry')
      end

      it 'finds David and Daniel but not Terry' do
        expect(result).to include('David')
        expect(result).to include('Daniel')
        expect(result).not_to include('Terry')
      end
    end

    describe 'middle_name' do
      let(:attribute) { 'middle_name' }
      let(:term) { 'Da' }

      before do
        create(:person, middle_name: 'David')
        create(:person, middle_name: 'Daniel')
        create(:person, middle_name: 'Darrell')
        create(:person, middle_name: 'Terry')
      end

      it 'finds David and Daniel but not Terry' do
        expect(result).to include('David')
        expect(result).to include('Daniel')
        expect(result).not_to include('Terry')
      end
    end

    describe 'last_name' do
      let(:attribute) { 'last_name' }
      let(:term) { 'Fu' }

      before do
        create(:person, last_name: 'Furber')
        create(:person, last_name: 'Furr')
        create(:person, last_name: 'Furlong')
        create(:person, last_name: 'Farber')
      end

      it 'finds Furr and Furber but not Farber' do
        expect(result).to include('Furber')
        expect(result).to include('Furr')
        expect(result).not_to include('Farber')
      end
    end
  end

  context 'with address fields' do
    describe 'street_name' do
      let(:attribute) { 'street_name' }
      let(:term) { 'Ti' }

      before do
        create(:building, addresses: [build(:address, name: 'Cayuga')])
        create(:building, addresses: [build(:address, name: 'Tioga')])
        create(:building, addresses: [build(:address, name: 'Tioga')])
        create(:building, addresses: [build(:address, name: 'Titus')])
      end

      it 'has matching streets' do
        expect(result.length).to eq(2)
        expect(result).to include('Tioga')
        expect(result).to include('Titus')
      end

      it 'has no non-matching streets' do
        expect(result).not_to include('Cayuga')
      end
    end

    describe 'street_house_number' do
      let(:attribute) { 'street_house_number' }
      let(:term) { '405' }

      before do
        create(:building, addresses: [build(:address, house_number: '405')])
        create(:building, addresses: [build(:address, house_number: '405')])
        create(:building, addresses: [build(:address, house_number: '4050')])
        create(:building, addresses: [build(:address, house_number: '407')])
      end

      it 'has matching streets' do
        expect(result.length).to eq(2)
        expect(result).to include('405')
        expect(result).to include('4050')
      end

      it 'has no non-matching streets' do
        expect(result).not_to include('407')
      end
    end

    describe 'street_address' do
      let(:attribute) { 'street_address' }
      let(:term) { '405 N Ti' }

      before do
        create(:building, addresses: [build(:address, house_number: '405', name: 'Tioga', prefix: 'N', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '405', name: 'Titus', prefix: 'N', suffix: 'Ave')])
        create(:building, addresses: [build(:address, house_number: '405', name: 'Tioga', prefix: 'S', suffix: 'St')])
        create(:building, addresses: [build(:address, house_number: '405', name: 'Cayuga', prefix: 'N', suffix: 'St')])
      end

      it 'has matching streets' do
        expect(result.length).to eq(2)
        expect(result).to include('405 N Tioga St Ithaca')
        expect(result).to include('405 N Titus Ave Ithaca')
      end

      it 'has no non-matching streets' do
        expect(result).not_to include('405 S Tioga St Ithaca')
        expect(result).not_to include('405 N Cayuga St Ithaca')
      end
    end
  end
end
