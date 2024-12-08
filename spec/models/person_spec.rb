# == Schema Information
#
# Table name: people
#
#  id                      :integer          not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  last_name               :string
#  first_name              :string
#  middle_name             :string
#  sex                     :string(12)
#  race                    :string
#  name_prefix             :string
#  name_suffix             :string
#  searchable_name         :text
#  birth_year              :integer
#  is_birth_year_estimated :boolean          default(TRUE)
#  pob                     :string
#  is_pob_estimated        :boolean          default(TRUE)
#  notes                   :text
#  description             :text
#  sortable_name           :string
#
# Indexes
#
#  people_name_trgm  (searchable_name) USING gist
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person do
  context 'when creating a record' do
    let(:person) { build(:person, middle_name: 'Jimmy', name_suffix: 'Jr', name_prefix: 'Dr') }

    it 'automatically creates a name variant with all the name parts' do
      primary_name = person.names.first
      expect(primary_name.first_name).to eq person.first_name
      expect(primary_name.last_name).to eq person.last_name
      expect(primary_name.middle_name).to eq person.middle_name
      expect(primary_name.name_prefix).to eq person.name_prefix
      expect(primary_name.name_suffix).to eq person.name_suffix
    end
  end

  describe '#estimated_birth_year' do
    context 'with a birth year' do
      let(:person) { build(:person, birth_year: 1872, is_birth_year_estimated: false) }

      it 'returns the birth year' do
        expect(person.estimated_birth_year).to eq(person.birth_year)
      end
    end

    context 'with multiple census records that all have an age' do
      subject { person.estimated_birth_year }

      let(:person) do
        build(:person,
              census1900_records: [build(:census1900_record, age: 28)],
              census1910_records: [build(:census1910_record, age: 38)],
              census1920_records: [build(:census1920_record, age: 48)],
              census1930_records: [build(:census1930_record, age: 58)],
              census1940_records: [build(:census1940_record, age: 68)])
      end

      it { is_expected.to eq 1872 }
    end

    context 'with multiple census records that will not all have an age because one is a baby' do
      subject { person.estimated_birth_year }

      let(:person) do
        build(:person,
              census1900_records: [build(:census1900_record, age: nil)],
              census1910_records: [build(:census1910_record, age: 10)],
              census1920_records: [build(:census1920_record, age: 20)],
              census1930_records: [build(:census1930_record, age: 30)],
              census1940_records: [build(:census1940_record, age: 40)])
      end

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

    context 'when the person has no age' do
      let(:person) { build(:person, birth_year: nil) }

      it 'returns true' do
        expect(person.similar_in_age?(1900, 90)).to be true
      end
    end

    context 'when same age' do
      it 'returns true' do
        expect(person.similar_in_age?(1900, 28)).to be true
      end
    end

    context 'when a year apart' do
      it 'returns true' do
        expect(person.similar_in_age?(1900, 27)).to be true
      end
    end

    context 'when 2 years apart' do
      it 'returns true' do
        expect(person.similar_in_age?(1900, 26)).to be true
      end
    end

    context 'when 6 years apart' do
      it 'returns false' do
        expect(person.similar_in_age?(1900, 20)).to be false
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
      let(:record) { create(:census1900_record, birth_year: 1876, age: 25, first_name: person.first_name, middle_name: person.middle_name, last_name: person.last_name) }

      it 'does not duplicate the name on the person record' do
        person.add_name_from(record)
        expect(person.names.length).to eq(1)
        name = person.names.first.name
        expect(name).to eq([record.first_name, record.last_name].join(' '))
      end
    end

    context 'when the person does not have the name yet' do
      let(:person) { create(:person, first_name: 'Robert', last_name: 'Kibbee') }
      let(:record) { create(:census1900_record, birth_year: 1876, age: 25, first_name: 'Bob', last_name: 'Kibbee') }

      before { person.add_name_from(record) }

      it 'adds the name to the person record' do
        expect(person.names.length).to eq(2)
        name = person.names.last.name
        expect(name).to eq([record.first_name, record.last_name].join(' '))
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
