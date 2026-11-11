# frozen_string_literal: true

require "rails_helper"

module People
  RSpec.describe LikelyMatches do
    subject { suggestions.first.person }
    let(:suggestions) { described_class.call(record:) }
    let(:record) { FactoryBot.create(:census1910_record, first_name: "David", last_name: "Furber", sex: "m", race: "W") }
    let(:non_matching_person) { FactoryBot.create(:person, first_name: "Michael", last_name: "Furber", sex: "m", race: "W") }

    before do
      Census1910Record.where(first_name: "David", last_name: "Furber", sex: "m", race: "W").delete_all
      # Automatic matching only engages when there is more than one census going.
      # Otherwise, partners get confused by "mystery matches" when logically
      # there shouldn't be an existing person record for anyone yet. That's why
      # we are creating a random record in another census year.
      FactoryBot.create(:census1920_record)
      matching_person
      non_matching_person
    end

    context "when there is an exact match" do
      let(:matching_person) { FactoryBot.create(:person, first_name: "David", last_name: "Furber", sex: "m", race: "W") }

      it { is_expected.to eq(matching_person) }
    end

    context "when there is a same last name and cognate first name match" do
      let!(:matching_person) { FactoryBot.create(:person, first_name: "Dave", last_name: "Furber", sex: "m", race: "W") }

      it { is_expected.to eq(matching_person) }
    end

    context "when there is a same last name and cognate middle name match" do
      let!(:matching_person) { FactoryBot.create(:person, first_name: "B", middle_name: "Dave", last_name: "Furber", sex: "m", race: "W") }

      it { is_expected.to eq(matching_person) }
    end

    context "when there is a similar last name and cognate first name match" do
      let!(:matching_person) { FactoryBot.create(:person, first_name: "Dave", last_name: "Ferber", sex: "m", race: "W") }

      it { is_expected.to eq(matching_person) }
    end

    context "when a middle initial accompanies a surname spelling variant" do
      let(:record) do
        create(:census1910_record, first_name: "Wilson", middle_name: "Q", last_name: "Blakslie", sex: "M", age: 30)
      end
      let(:matching_person) { create(:person, first_name: "Wilson", last_name: "Blakeslee", sex: "M", birth_year: 1880) }

      it "keeps the spelling variant below a stronger match without adding surname-only matches" do
        stronger = create(:person, first_name: "Wilson", last_name: "Blakslie", sex: "M", birth_year: 1880)
        create(:person, first_name: "Abraham", last_name: "Blakslie", sex: "M", birth_year: 1880)
        create(:census1920_record, person: matching_person, first_name: "Wilson", last_name: "Blakeslee", age: 40)

        expect(suggestions.map(&:person)).to eq([stronger, matching_person])
        expect(suggestions.map(&:reason)).to eq([
          "Same given or middle name and surname",
          "Matching given name or nickname and similar surname"
        ])
      end
    end

    context "when a nickname is stored as a capitalized middle name" do
      let(:record) { create(:census1910_record, first_name: "Burton", last_name: "Furber", sex: "M") }
      let(:matching_person) { create(:person, first_name: "John", middle_name: "Bert", last_name: "Furber", sex: "M") }

      it "recognizes the nickname as stronger evidence than the surname alone" do
        expect(suggestions.first.person).to eq(matching_person)
        expect(suggestions.first.reason).to eq("Known nickname and same surname")
      end
    end

    context "when earlier surname-only candidates are outside the age window" do
      let(:record) { create(:census1910_record, first_name: "Eli", middle_name: nil, last_name: "Ng", sex: "M", age: 30) }
      let(:matching_person) { create(:person, first_name: "Zebulon", last_name: "Ng", sex: "M", birth_year: 1880) }

      it "applies the age check before limiting candidates" do
        %w[Aaron Adam Alan Alfred Amos Arnold Arthur Barry Bruce Carl].each do |name|
          create(:person, first_name: name, last_name: "Ng", sex: "M", birth_year: 1850)
        end

        expect(suggestions.map(&:person)).to eq([matching_person])
        expect(suggestions.first.reason).to eq("Same surname only")
      end
    end

    context "when the census age is unavailable" do
      let(:matching_person) { create(:person, first_name: "David", last_name: "Furber", sex: "m", birth_year: 1880) }

      [nil, -1, 999].each do |unknown_age|
        it "retains a matching person for age #{unknown_age.inspect}" do
          record.age = unknown_age

          expect(suggestions.map(&:person)).to include(matching_person)
        end
      end
    end

    context "when a stored variant matches through more than one name" do
      let(:record) do
        FactoryBot.create(:census1910_record, first_name: "Quentin", middle_name: nil, last_name: "Furber", sex: "m", race: "W")
      end
      let(:matching_person) { FactoryBot.create(:person, first_name: "Furber", last_name: "Quentin", sex: "m", race: "W") }

      it "suggests the person once, using their strongest name evidence" do
        create(:person_name, person: matching_person, first_name: "Zachary", last_name: "Furber")

        expect(suggestions.map(&:person)).to eq([matching_person])
        expect(suggestions.first.reason).to eq("Given name and surname appear reversed")
      end
    end
  end
end
