# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEntity do
  describe '.build_from' do
    let(:person) { build(:person) }
    let(:year) { 1920 }

    context 'when person is nil' do
      it 'returns nil' do
        expect(PersonEntity.build_from(nil, year)).to be_nil
      end
    end

    context 'when person has no census records' do
      before do
        allow(person).to receive(:census1920_records).and_return([])
      end

      it 'returns nil' do
        expect(PersonEntity.build_from(person, year)).to be_nil
      end
    end

    context 'when person has census records' do
      let(:census_record) { build(:census_record) }

      before do
        allow(person).to receive(:census1920_records).and_return([census_record])
      end

      it 'returns a PersonEntity' do
        result = PersonEntity.build_from(person, year)
        expect(result).to be_a(PersonEntity)
        expect(result.id).to eq(person.id)
        expect(result.year).to eq(year)
      end

      it 'includes census records in properties' do
        result = PersonEntity.build_from(person, year)
        expect(result.properties[:census_records]).to be_present
        expect(result.properties[:census_records].first).to be_a(Hash)
      end
    end
  end
end
