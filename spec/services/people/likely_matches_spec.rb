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

    context "when the surname agrees and the given name is weakly similar" do
      let(:record) { build(:census1880_record, first_name: "Jackson", last_name: "Tupper", sex: "M", age: 26) }
      let(:matching_person) { create(:person, first_name: "Judson", last_name: "Tupper", sex: "M", birth_year: 1853) }

      it "suggests Judson even when a stronger name match is available" do
        create(:census1910_record)
        exact = create(:person, first_name: "Jackson", last_name: "Tupper", sex: "M", birth_year: 1854)

        expect(suggestions.map(&:person)).to eq([exact, matching_person])
        expect(suggestions.last.reason).to eq("Similar given or middle name and same surname")
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

    context "when the 1950 census gives an infant's birth month" do
      let(:record) do
        create(:census1950_record, first_name: "Ivan", last_name: "Robinson", sex: "M", age: nil, birth_month: 8,
               locality: create(:locality), page_number: 1, page_side: "A", line_number: 1,
               enum_dist: "1", family_id: "1", relation_to_head: "Son")
      end
      let(:matching_person) { create(:person, first_name: "Ivan", last_name: "Robinson", sex: "M", birth_year: 1944) }

      it "uses the estimated 1949 birth year for the five-year matching window" do
        create(:person, first_name: "Ivan", last_name: "Robinson", sex: "M", birth_year: 1907)
        create(:person, first_name: "Ivan", last_name: "Robinson", sex: "M", birth_year: 1943)

        expect(suggestions.map(&:person)).to eq([matching_person])
      end
    end

    context "when 1920 records an infant's age in months" do
      let(:record) { create(:census1920_record, first_name: "Ivan", last_name: "Robinson", sex: "M", age: nil, age_months: 1) }
      let(:matching_person) { create(:person, first_name: "Ivan", last_name: "Robinson", sex: "M", birth_year: 1914) }

      it "uses the estimated 1919 birth year for the five-year matching window" do
        create(:census1910_record)
        create(:person, first_name: "Ivan", last_name: "Robinson", sex: "M", birth_year: 1913)

        expect(suggestions.map(&:person)).to eq([matching_person])
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
