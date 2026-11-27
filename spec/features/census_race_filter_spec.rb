# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Census race filters' do
  scenario 'searches for a specific 1950 write-in and keeps it in the active filters', :js do
    visit census_records_path(year: 1950)
    click_button 'Add filter'
    select 'Race'
    check 'Other', exact: true
    find('input[aria-label="Other race as recorded"]').set('Asiatic Indian')
    click_button 'Apply filters'

    expect(page).to have_css('#attribute-filters', text: 'Other: Asiatic Indian')
    filters = Rack::Utils.parse_nested_query(URI.parse(page.current_url).query).fetch('s')
    expect(filters.fetch('race_in')).to eq(['Asiatic Indian'])
  end
end
