# frozen_string_literal: true

require 'rails_helper'

module People
  RSpec.describe LikelyMatches do
    subject { described_class.run!(record:) }
    let(:record) { FactoryBot.create(:census1910_record, first_name: target_first_name, last_name: target_last_name, sex: 'm', race: 'w') }
    let(:target_first_name) { 'David' }
    let(:target_last_name) { 'Furber' }
    context 'when there is an exact match' do
      let!(:person1) { FactoryBot.create(:person, first_name: 'David', last_name: 'Furber', sex: 'm', race: 'W') }
      let!(:person2) { FactoryBot.create(:person, first_name: 'Dylan', last_name: 'Furber', sex: 'm', race: 'W') }
      it 'returns the exact match' do
        expect(subject.first).to eq(person1)
      end
    end
    context 'when there is a same last name and cognate first name match' do
      let!(:person1) { FactoryBot.create(:person, first_name: 'Dave', last_name: 'Furber', sex: 'm', race: 'W') }
      let!(:person2) { FactoryBot.create(:person, first_name: 'Dylan', last_name: 'Furber', sex: 'm', race: 'W') }
      it 'returns the exact match' do
        expect(subject.first).to eq(person1)
      end
    end
    context 'when there is a similar last name and cognate first name match' do
      let!(:person1) { FactoryBot.create(:person, first_name: 'Dave', last_name: 'Ferber', sex: 'm', race: 'W') }
      let!(:person2) { FactoryBot.create(:person, first_name: 'Dylan', last_name: 'Furber', sex: 'm', race: 'W') }
      it 'returns the exact match' do
        expect(subject.first).to eq(person1)
      end
    end
  end
end
