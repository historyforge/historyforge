# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::GenerateFromCensusRecord do
  let(:person) { described_class.call(record:) }
  let(:record) { create(:census1900_record, birth_year: 1872, age: 28) }

  it { expect(person.race).to eq(record.race) }
  it { expect(person.sex).to eq(record.sex) }
  it { expect(person.first_name).to eq(record.first_name) }
  it { expect(person.middle_name).to eq(record.middle_name) }
  it { expect(person.last_name).to eq(record.last_name) }
  it { expect(person.id).to(eq(record.person_id)) }

  context 'when the 1910 census gives an infant age in months' do
    let(:record) { create(:census1910_record, age: nil, age_months: 7) }

    it 'saves an estimate that can be recalculated from the census record' do
      expect(person.reload).to have_attributes(birth_year: 1909, is_birth_year_estimated: true)
      expect(person.estimated_birth_year).to eq(1909)
    end
  end

  context 'when the 1950 census gives an infant birth month' do
    let(:record) do
      create(:census1950_record, first_name: 'Ivan', last_name: 'Robinson', sex: 'M', race: 'W', age: nil, birth_month: month,
             locality: create(:locality), page_number: 1, page_side: 'A', line_number: 1,
             enum_dist: '1', family_id: '1', relation_to_head: 'Son')
    end

    { 3 => 1950, 4 => 1949, 8 => 1949 }.each do |birth_month, year|
      context "when the birth month is #{Date::MONTHNAMES.fetch(birth_month)}" do
        let(:month) { birth_month }

        it 'saves an estimated birth year that can be recalculated from the census record' do
          expect(person.reload).to have_attributes(birth_year: year, is_birth_year_estimated: true)
          expect(person.estimated_birth_year).to eq(year)
        end
      end
    end
  end
end
