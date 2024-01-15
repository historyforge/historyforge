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
      before do
        subject.birth_year = 1872
        subject.is_birth_year_estimated = false
      end

      it 'returns the birth year' do
        expect(subject.estimated_birth_year).to eq(subject.birth_year)
      end
    end

    context 'with multiple census records that all have an age' do
      before do
        subject.census1900_records << build(:census1900_record, age: 28)
        subject.census1910_records << build(:census1910_record, age: 38)
        subject.census1920_records << build(:census1920_record, age: 48)
        subject.census1930_records << build(:census1930_record, age: 58)
        subject.census1940_records << build(:census1940_record, age: 68)
      end

      it 'returns the correct birth year' do
        expect(subject.estimated_birth_year).to eq(1872)
      end
    end

    context 'with multiple census records that will not all have an age because one is a baby' do
      before do
        subject.census1900_records << build(:census1900_record, age: nil)
        subject.census1910_records << build(:census1910_record, age: 10)
        subject.census1920_records << build(:census1920_record, age: 20)
        subject.census1930_records << build(:census1930_record, age: 30)
        subject.census1940_records << build(:census1940_record, age: 40)
      end

      it 'returns the correct birth year' do
        expect(subject.estimated_birth_year).to eq(1900)
      end
    end
  end

  describe '#age_in_year' do
    context 'with a birth year' do
      before do
        subject.birth_year = 1872
        subject.is_birth_year_estimated = false
      end

      it 'calculates the age based on the birth year' do
        expect(subject.age_in_year(1900)).to eq(28)
      end
    end

    context 'without a birth year' do
      before do
        subject.census1900_records << build(:census1900_record, birth_year: 1872, age: 28)
      end

      it 'calculates the age based on the birth year of the census record' do
        expect(subject.age_in_year(1900)).to eq(28)
      end
    end

    context 'returns 0 for a baby' do
      before do
        subject.census1900_records << build(:census1900_record, birth_year: 1900, age: 0)
      end

      it 'calculates the age based on the birth year of the census record' do
        expect(subject.age_in_year(1900)).to eq(0)
      end
    end
  end

  describe '#similar_in_age?' do
    before { subject.birth_year = 1872 }

    context 'when same age' do
      let(:record) { build(:census1900_record, birth_year: 1872, age: 28) }

      it 'returns true' do
        expect(subject).to be_similar_in_age(record)
      end
    end

    context 'when a year apart' do
      let(:record) { build(:census1900_record, birth_year: 1873, age: 27) }

      it 'returns true' do
        expect(subject).to be_similar_in_age(record)
      end
    end

    context 'when 2 years apart' do
      let(:record) { build(:census1900_record, birth_year: 1874, age: 26) }

      it 'returns true' do
        expect(subject).to be_similar_in_age(record)
      end
    end

    context 'when 3 years apart' do
      let(:record) { build(:census1900_record, birth_year: 1876, age: 25) }

      it 'returns true' do
        expect(subject).not_to be_similar_in_age(record)
      end
    end
  end

  describe '#census_records' do
    let(:record) { build(:census1900_record, birth_year: 1876, age: 25) }

    before { subject.census1900_records << record }

    it 'returns the census record from 1900' do
      expect(subject.census_records).to eq([record])
    end
  end

  describe '#add_name_from' do
    subject { create(:person) }

    context 'when the person already has the name' do
      let(:primary_name) { subject.primary_name }
      let(:record) { create(:census1900_record, birth_year: 1876, age: 25, first_name: subject.primary_name.first_name, middle_name: subject.primary_name.middle_name, last_name: subject.primary_name.last_name) }

      it 'does not duplicate the name on the person record' do
        subject.add_name_from(record)
        expect(subject.names.length).to eq(1)
        name = subject.names.first.name
        expect(name).to eq(record.name)
      end
    end

    context 'when the person does not have the name yet' do
      let(:record) { create(:census1900_record, birth_year: 1876, age: 25) }

      before { subject.add_name_from(record) }

      it 'adds the name to the person record' do
        expect(subject.names.length).to eq(2)
        name = subject.names.last.name
        expect(name).to eq(record.name)
      end
    end
  end
end
