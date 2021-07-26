require 'rails_helper'

RSpec.describe Person do
  describe '#age_in_year' do
    context 'with a birth year' do
      before do
        subject.birth_year = 1872
      end
      it 'calculates the age based on the birth year' do
        expect(subject.age_in_year(1900)).to eq(28)
      end
    end
    context 'without a birth year' do
      before do
        subject.census_1900_record = build(:census1900_record, birth_year: 1872, age: 28)
      end
      it 'calculates the age based on the birth year of the census record' do
        expect(subject.age_in_year(1900)).to eq(28)
      end
    end
    context 'returns 0 for a baby' do
      before do
        subject.census_1900_record = build(:census1900_record, birth_year: 1900, age: 0)
      end
      it 'calculates the age based on the birth year of the census record' do
        expect(subject.age_in_year(1900)).to eq(0)
      end
    end
  end

  describe '#similar_in_age?' do
    context 'when same age' do
      let(:record) { build(:census1900_record, birth_year: 1872, age: 28) }
      before {
        subject.birth_year = 1872
      }
      it 'returns true' do
        expect(subject.similar_in_age?(record)).to be_truthy
      end
    end
    context 'when a year apart' do
      let(:record) { build(:census1900_record, birth_year: 1873, age: 27) }
      before {
        subject.birth_year = 1872
      }
      it 'returns true' do
        expect(subject.similar_in_age?(record)).to be_truthy
      end
    end
    context 'when 2 years apart' do
      let(:record) { build(:census1900_record, birth_year: 1874, age: 26) }
      before {
        subject.birth_year = 1872
      }
      it 'returns true' do
        expect(subject.similar_in_age?(record)).to be_truthy
      end
    end
    context 'when 3 years apart' do
      let(:record) { build(:census1900_record, birth_year: 1876, age: 25) }
      before {
        subject.birth_year = 1872
      }
      it 'returns true' do
        expect(subject.similar_in_age?(record)).to be_falsey
      end
    end
  end

  describe '#census_records' do
    let(:record) { build(:census1900_record, birth_year: 1876, age: 25) }
    before do
      subject.census_1900_record = record
    end
    it 'returns the census record from 1900' do
      expect(subject.census_records).to eq([record])
    end
  end
end
