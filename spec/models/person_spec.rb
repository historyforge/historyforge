# == Schema Information
#
# Table name: people
#
#  id                      :integer          not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  sex                     :string(12)
#  race                    :string
#  birth_year              :integer
#  is_birth_year_estimated :boolean          default(TRUE)
#  pob                     :string
#  is_pob_estimated        :boolean          default(TRUE)
#  notes                   :text
#  description             :text
#
# Indexes
#
#  people_name_trgm  (searchable_name) USING gist
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person do
  describe '#estimated_birth_year' do
    context 'with a birth year' do
      let(:person) { build(:person, birth_year: 1872, is_birth_year_estimated: false) }

      it 'returns the birth year' do
        expect(person.estimated_birth_year).to eq(person.birth_year)
      end
    end

    context 'with multiple census records that all have an age' do
      let(:person) do
        build(:person,
              census1900_records: [build(:census1900_record, age: 28)],
              census1910_records: [build(:census1910_record, age: 38)],
              census1920_records: [build(:census1920_record, age: 48)],
              census1930_records: [build(:census1930_record, age: 58)],
              census1940_records: [build(:census1940_record, age: 68)])
      end
      subject { person.estimated_birth_year }

      it { is_expected.to eq 1872 }
    end

    context 'with multiple census records that will not all have an age because one is a baby' do
      let(:person) do
        build(:person,
              census1900_records: [build(:census1900_record, age: nil)],
              census1910_records: [build(:census1910_record, age: 10)],
              census1920_records: [build(:census1920_record, age: 20)],
              census1930_records: [build(:census1930_record, age: 30)],
              census1940_records: [build(:census1940_record, age: 40)])
      end
      subject { person.estimated_birth_year }

      it { is_expected.to eq 1900 }
    end
  end

  describe '#age_in_year' do
    context 'with a birth year' do
      let(:person) { build(:person, birth_year: 1872, is_birth_year_estimated: false) }

      it 'calculates the age based on the birth year' do
        expect(person.age_in_year(1900)).to eq(28)
      end
    end

    context 'without a birth year' do
      let(:person) { build(:person, census1900_records: [build(:census1900_record, birth_year: 1872, age: 28)]) }

      it 'calculates the age based on the birth year of the census record' do
        expect(person.age_in_year(1900)).to eq(28)
      end
    end

    context 'when the person is a baby' do
      let(:person) { build(:person, census1900_records: [build(:census1900_record, birth_year: 1900, age: 0)]) }

      it 'calculates the age based on the birth year of the census record' do
        expect(person.age_in_year(1900)).to eq(0)
      end
    end
  end

  describe '#similar_in_age?' do
    let(:person) { build(:person, birth_year: 1872) }

    context 'when same age' do
      let(:record) { build(:census1900_record, birth_year: 1872, age: 28) }

      it 'returns true' do
        expect(person).to be_similar_in_age(record)
      end
    end

    context 'when a year apart' do
      let(:record) { build(:census1900_record, birth_year: 1873, age: 27) }

      it 'returns true' do
        expect(person).to be_similar_in_age(record)
      end
    end

    context 'when 2 years apart' do
      let(:record) { build(:census1900_record, birth_year: 1874, age: 26) }

      it 'returns true' do
        expect(person).to be_similar_in_age(record)
      end
    end

    context 'when 3 years apart' do
      let(:record) { build(:census1900_record, birth_year: 1876, age: 25) }

      it 'returns true' do
        expect(person).not_to be_similar_in_age(record)
      end
    end
  end

  describe '#census_records' do
    let(:person) { build(:person, census1900_records: [record]) }
    let(:record) { build(:census1900_record, birth_year: 1876, age: 25) }

    it 'returns the census record from 1900' do
      expect(person.census_records).to eq([record])
    end
  end

  describe '#add_name_from' do
    subject { create(:person) }

    context 'when the person already has the name' do
      let(:person) { create(:person) }
      let(:primary_name) { person.primary_name }
      let(:record) { create(:census1900_record, birth_year: 1876, age: 25, first_name: person.primary_name.first_name, middle_name: person.primary_name.middle_name, last_name: person.primary_name.last_name) }

      it 'does not duplicate the name on the person record' do
        person.add_name_from(record)
        expect(person.names.length).to eq(1)
        name = person.names.first.name
        expect(name).to eq(record.name)
      end
    end

    context 'when the person does not have the name yet' do
      let(:person) { create(:person) }
      let(:record) { create(:census1900_record, birth_year: 1876, age: 25) }

      before { person.add_name_from(record) }

      it 'adds the name to the person record' do
        expect(person.names.length).to eq(2)
        name = person.names.last.name
        expect(name).to eq(record.name)
      end
    end
  end

  describe '#add_locality_from' do
    context 'when the person does not have the location yet' do
      let(:locality) { create(:locality) }
      let(:record) { create(:census1900_record, birth_year: 1876, age: 25, locality:) }
      let(:person) { create(:person, localities: []) }

      before { person.add_locality_from(record) }

      it 'adds the locality to the person record' do
        expect(person.localities.length).to eq(1)
        expect(person.locality_ids).to contain_exactly(record.locality_id)
      end
    end
  end
end
