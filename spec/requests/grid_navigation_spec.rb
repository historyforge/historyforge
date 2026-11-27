# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search result navigation', type: :request do
  include Devise::Test::IntegrationHelpers

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

  it 'preserves the Census grid context through editing and a failed save' do
    sign_in create(:administrator)
    youngest = create(:census1910_record, age: 20, last_name: 'Brown')
    middle = create(:census1910_record, age: 30, last_name: 'Brown')
    oldest = create(:census1910_record, age: 40, last_name: 'Brown')
    create(:census1910_record, age: 35, last_name: 'Jones')

    search = { 's' => { 'last_name_eq' => 'Brown' }, 'scope' => 'unhoused',
               'sort' => { '0' => { 'colId' => 'age', 'sort' => 'desc' } } }
    get census_records_path(year: 1910, format: :json), params: search.merge(from: 1, to: 2)
    row = response.parsed_body.sole.fetch('name')
    expect(row.fetch('id')).to eq(middle.id)

    show_path = row.fetch('href')
    get show_path
    edit_path = edit_census_record_path(year: 1910, id: middle.id)
    edit_link = Nokogiri::HTML(response.body).at_css("a[href^='#{edit_path}']")
    get edit_link['href']
    expect(response).to have_http_status(:ok)
    edit_page = Nokogiri::HTML(response.body)
    expect(edit_page.css('a').find { |link| link.text == 'View' }['href']).to eq(show_path)
    view_all = edit_page.css('a').find { |link| link.text == 'View All' }['href']
    expect(Rack::Utils.parse_nested_query(URI.parse(view_all).query)).to include(search)

    patch edit_page.at_css('form.simple_form')['action'], params: { census_record: { last_name: '' } }
    expect(response).to have_http_status(:unprocessable_content)
    retry_form = Nokogiri::HTML(response.body).at_css('form.simple_form')

    patch retry_form['action'], params: { census_record: { first_name: 'Bert' } }
    expect(response).to redirect_to(show_path)
    expect(middle.reload.first_name).to eq('Bert')
    follow_redirect!
    expect(navigation_links.map { |link| URI.parse(link).path }).to eq([
      census_record_path(year: 1910, id: oldest.id),
      census_record_path(year: 1910, id: youngest.id),
    ])

    patch retry_form['action'], params: { census_record: { last_name: 'Jones' } }
    expect(response).to redirect_to(show_path)
    follow_redirect!
    expect(navigation_links).to eq([nil, nil])
    breadcrumb = Nokogiri::HTML(response.body).at_css('nav[aria-label="breadcrumb"] a')['href']
    expect(breadcrumb).to eq(view_all)
  end
end
