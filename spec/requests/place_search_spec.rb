# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Place search', type: :request do
  it 'filters buildings by the Place on their primary address' do
    matching = create(:building, :reviewed, addresses: [
                        build(:address, city: 'Cayuga Heights'),
                        build(:address, city: 'Forest Home', is_primary: false)
                      ])
    other = create(:building, :reviewed, addresses: [build(:address, city: 'Forest Home')])
    create(:address, building: other, city: 'Cayuga Heights', is_primary: false)

    {
      { city_eq: 'cayuga heights' } => [matching.id],
      { city_cont: 'cayuga' } => [matching.id],
      { city_not_cont: 'cayuga' } => [other.id],
      { city_eq: 'unknown place' } => []
    }.each do |filters, ids|
      get buildings_path(format: :json), params: { s: filters, from: 0, to: 100 }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.map { |row| row.dig('street_address', 'id') }).to eq(ids)
    end
  end

  it 'matches the census record’s own Place regardless of capitalization' do
    matching = create(:census1920_record, city: 'Forest Home')
    other = create(:census1920_record, city: 'Ithaca')
    [matching, other].each { |record| record.update_columns(reviewed_at: Time.current) }

    [
      { city_eq: 'forest home' },
      { city_start: 'fOrEsT' },
      { city_cont: 'home' }
    ].each do |filters|
      get census_records_path(year: 1920, format: :json), params: { s: filters, from: 0, to: 100 }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.map { |row| row.dig('name', 'id') }).to eq([matching.id])
    end
  end
end
