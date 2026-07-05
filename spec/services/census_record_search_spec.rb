# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CensusRecordSearch do
  describe '#sheet_number_options' do
    let(:locality) { create(:locality) }
    let(:user) { create(:active_user) }

    before do
      Current.locality_id = locality.id
      create(:census1870_record,
             locality:,
             page_number: 250,
             line_number: 1,
             post_office: 'Ithaca',
             city: 'Ithaca',
             county: 'Tompkins',
             state: 'New York',
             first_name: 'John',
             last_name: 'Doe',
             family_id: '1',
             occupation: 'None')
    end

    after { Current.reset }

    it 'includes sheet numbers beyond the old 200 limit' do
      search = described_class.generate(year: 1870, params: { s: { page_number_eq: '250' } }, user:)
      expect(search.sheet_number_options).to include(250)
      expect(search.sheet_number_options.last).to eq(250)
    end

    it 'includes the selected sheet even when it exceeds the database maximum' do
      search = described_class.generate(year: 1870, params: { s: { page_number_eq: '300' } }, user:)
      expect(search.sheet_number_options).to include(300)
    end

    it 'defaults to at least 200 when no records exist' do
      Census1870Record.delete_all
      search = described_class.generate(year: 1870, params: {}, user:)
      expect(search.sheet_number_options).to eq((1..200).to_a)
    end
  end
end
