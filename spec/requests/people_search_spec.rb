# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'People search', type: :request do
  it 'matches first and last names regardless of capitalization, including alternate names' do
    person = create(:person, first_name: 'Amy', last_name: 'Atwater')
    create(:person_name, person:, first_name: 'Amelia', last_name: 'Smith')
    create(:person, first_name: 'Alice', last_name: 'Robinson')

    [
      { names_last_name_eq: 'atwater' },
      { names_last_name_start: 'aTw' },
      { names_last_name_cont: 'TwAt' },
      { names_first_name_eq: 'AMELIA', names_last_name_eq: 'smith' }
    ].each do |filters|
      get people_path(format: :json), params: { s: filters, from: 0, to: 100 }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.map { |row| row.dig('name', 'id') }).to eq([person.id])
    end
  end

  it 'sorts by surname before given name and follows that order in record navigation' do
    longer = create(:person, first_name: 'Abram', last_name: 'Colegrove')
    later = create(:person, first_name: 'Haines', last_name: 'Cole')
    earlier = create(:person, first_name: 'Jenny', last_name: 'Zimmer')
    alternate = create(:person_name, person: earlier, first_name: 'Abby', last_name: 'Cole')

    # Reproduce the order of the old combined sort keys regardless of the test database collation.
    longer.names.first.update_columns(sortable_name: '1')
    later.names.first.update_columns(sortable_name: '2')
    alternate.update_columns(sortable_name: '3')

    filters = { s: { names_last_name_start: 'cole' } }
    get people_path(format: :json), params: filters.merge(from: 0, to: 100)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.map { |row| row.dig('name', 'id') }).to eq([earlier.id, later.id, longer.id])

    descending = filters.merge(sort: { '0' => { colId: 'name', sort: 'desc' } })
    get people_path(format: :json), params: descending.merge(from: 0, to: 100)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.map { |row| row.dig('name', 'id') }).to eq([longer.id, later.id, earlier.id])

    get people_path, params: descending
    expect(response).to have_http_status(:ok)
    get person_path(later)
    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    expect(page.at_css('a:has(.fa-chevron-left)')['href']).to eq(person_path(longer))
    expect(page.at_css('a:has(.fa-chevron-right)')['href']).to eq(person_path(earlier))
  end
end
