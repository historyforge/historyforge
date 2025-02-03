# frozen_string_literal: true

require 'rails_helper'

module People
  RSpec.describe LikelyMatches do
    subject { outcome[:matches].first }
    let(:outcome) { described_class.run!(record:) }
    let(:record) { FactoryBot.create(:census1910_record, first_name: 'David', last_name: 'Furber', sex: 'm', race: 'w') }
    let(:non_matching_person) { FactoryBot.create(:person, first_name: 'Michael', last_name: 'Furber', sex: 'm', race: 'W') }

    before do
      # Automatic matching only engages when there is more than one census going.
      # Otherwise, partners get confused by "mystery matches" when logically
      # there shouldn't be an existing person record for anyone yet. That's why
      # we are creating a random record in another census year.
      FactoryBot.create(:census1920_record)
      matching_person
      non_matching_person
    end

    context 'when there is an exact match' do
      let(:matching_person) { FactoryBot.create(:person, first_name: 'David', last_name: 'Furber', sex: 'm', race: 'W') }

      it { is_expected.to eq(matching_person) }
    end

    context 'when there is a same last name and cognate first name match' do
      let!(:matching_person) { FactoryBot.create(:person, first_name: 'Dave', last_name: 'Furber', sex: 'm', race: 'W') }

      it { is_expected.to eq(matching_person) }
    end

    context 'when there is a same last name and cognate middle name match' do
      let!(:matching_person) { FactoryBot.create(:person, first_name: 'B', middle_name: 'Dave', last_name: 'Furber', sex: 'm', race: 'W') }

      it { is_expected.to eq(matching_person) }
    end

    context 'when there is a similar last name and cognate first name match' do
      let!(:matching_person) { FactoryBot.create(:person, first_name: 'Dave', last_name: 'Ferber', sex: 'm', race: 'W') }

      it { is_expected.to eq(matching_person) }
    end
  end
end
