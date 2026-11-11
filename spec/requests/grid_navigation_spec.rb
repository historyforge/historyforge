# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search result navigation', type: :request do
  def navigation_links
    page = Nokogiri::HTML(response.body)
    [
      page.at_css('a:has(.fa-chevron-left)')&.[]('href'),
      page.at_css('a:has(.fa-chevron-right)')&.[]('href'),
    ]
  end

  it 'follows the unfiltered Buildings grid in the selected sort order' do
    earlier = create(:building, :reviewed, name: 'Alpha')
    middle = create(:building, :reviewed, name: 'Bravo')
    later = create(:building, :reviewed, name: 'Charlie')
    create(:building, name: 'Delta')

    get buildings_path(format: :json), params: { from: 1, to: 2, sort: { '0' => { colId: 'name', sort: 'desc' } } }
    expect(response).to have_http_status(:ok)
    row = response.parsed_body.sole.fetch('street_address')
    expect(row.fetch('id')).to eq(middle.id)

    get row.fetch('href')
    expect(response).to have_http_status(:ok)
    previous, following = navigation_links
    expect(URI.parse(previous).path).to eq(building_path(later))
    expect(URI.parse(following).path).to eq(building_path(earlier))

    get previous
    expect(response).to have_http_status(:ok)
    expect(navigation_links).to eq([nil, row.fetch('href')])
  end

  it 'keeps Census filters, scope, and sorting when moving between records' do
    reviewed_at = 1.day.ago
    youngest = create(:census1910_record, reviewed_at:, age: 20, last_name: 'Brown')
    middle = create(:census1910_record, reviewed_at:, age: 30, last_name: 'Brown')
    oldest = create(:census1910_record, reviewed_at:, age: 40, last_name: 'Brown')
    create(:census1910_record, reviewed_at:, age: 35, last_name: 'Brown', building: create(:building, :reviewed))
    create(:census1910_record, reviewed_at:, age: 35, last_name: 'Jones')

    get census_records_path(year: 1910, format: :json), params: {
      from: 1, to: 2, scope: 'unhoused', s: { last_name_eq: 'Brown' }, sort: { '0' => { colId: 'age', sort: 'desc' } },
    }
    expect(response).to have_http_status(:ok)
    row = response.parsed_body.sole.fetch('name')
    expect(row.fetch('id')).to eq(middle.id)

    get row.fetch('href')
    expect(response).to have_http_status(:ok)
    previous, following = navigation_links
    expect(URI.parse(previous).path).to eq(census_record_path(year: 1910, id: oldest.id))
    expect(URI.parse(following).path).to eq(census_record_path(year: 1910, id: youngest.id))

    get following
    expect(response).to have_http_status(:ok)
    expect(navigation_links).to eq([row.fetch('href'), nil])
  end
end
