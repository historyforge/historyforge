# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CensusRecord do
  describe 'duplicate validation on create' do
    let(:attributes) do
      {
        locality: create(:locality), page_number: 24, post_office: 'Caroline',
        family_id: '17', dwelling_number: '12', first_name: 'Mary', middle_name: 'A',
        last_name: 'Owens', age: 0, age_months: 4
      }
    end

    before { Census1860Record.create!(attributes.merge(line_number: 38)) }

    it 'blocks a matching person on another line in the same household' do
      record = Census1860Record.new(attributes.merge(line_number: 39))

      expect(record.save).to be(false)
      expect(record.errors[:base]).to include(
        'A person with the same name and age already exists in this census household on this sheet.'
      )
    end

    it 'still blocks an occupied line when the name differs' do
      record = Census1860Record.new(attributes.merge(line_number: 38, first_name: 'Jane'))

      expect(record.save).to be(false)
      expect(record.errors[:base]).to include(
        'A record already exists for this census sheet, side, and line number.'
      )
    end

    [
      { family_id: '18' },
      { dwelling_number: '13' },
      { page_number: 25 },
      { middle_name: 'B' },
      { age_months: 5 },
      { age: nil }
    ].each do |difference|
      it "allows a separate record with #{difference}" do
        record = Census1860Record.new(attributes.merge(line_number: 39).merge(difference))

        expect(record.save).to be(true), -> { record.errors.full_messages.to_sentence }
      end
    end
  end

  describe '1950 census households' do
    let(:attributes) do
      {
        locality: create(:locality), enum_dist: '1-1', page_number: 1, family_id: '5',
        first_name: 'Mary', last_name: 'Owens', age: 40, relation_to_head: 'Head'
      }
    end

    before { Census1950Record.create!(attributes.merge(line_number: 12)) }

    it 'blocks a matching person within the same household serial number' do
      expect(Census1950Record.new(attributes.merge(line_number: 13))).to be_invalid
    end

    it 'allows the same household serial number in another enumeration district' do
      record = Census1950Record.new(attributes.merge(enum_dist: '1-2', line_number: 12))

      expect(record.save).to be(true), -> { record.errors.full_messages.to_sentence }
    end
  end
end
