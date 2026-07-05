# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CensusRecordSearch do
  let(:locality) { create(:locality) }
  let(:user) { create(:active_user) }

  def build_search(params = {})
    described_class.generate(year: 1870, params:, user:)
  end

  def create_1870_record(page_number:)
    create(:census1870_record,
           locality:,
           page_number:,
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

  describe '#max_page_number' do
    before do
      Current.locality_id = locality.id
      create_1870_record(page_number: 250)
    end

    after { Current.reset }

    it 'reflects the highest page number in the database' do
      expect(build_search.s[:page_number_eq]).to be_nil
      expect(build_search.max_page_number).to eq(250)
    end

    it 'includes the selected page when it exceeds the database maximum' do
      expect(build_search(s: { page_number_eq: '300' }).max_page_number).to eq(300)
    end

    it 'returns zero when no records exist' do
      Census1870Record.delete_all
      expect(build_search.max_page_number).to eq(0)
    end
  end

  describe 'page number filter normalization' do
    before { Current.locality_id = locality.id }
    after { Current.reset }

    it 'preserves valid page numbers' do
      search = build_search(s: { page_number_eq: '250' })
      expect(search.s[:page_number_eq]).to eq('250')
    end

    it 'clamps page numbers above the maximum' do
      search = build_search(s: { page_number_eq: '99999' })
      expect(search.s[:page_number_eq]).to eq('10000')
    end

    it 'drops invalid page numbers' do
      search = build_search(s: { page_number_eq: 'abc' })
      expect(search.s[:page_number_eq]).to be_nil
    end
  end
end
