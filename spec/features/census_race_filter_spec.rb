# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Census race filters' do
  scenario 'searches for multiple 1950 write-ins and keeps them in the active filters', :js do
    visit census_records_path(year: 1950)
    click_button 'Add/edit filters'
    select 'Race'
    check 'Other', exact: true
    find('[data-write-in]').set('Asiatic Indian')
    click_button 'Add another write-in'
    all('[data-write-in]').last.set('Portuguese')
    click_button 'Apply filters'

    expect(page).to have_css('#attribute-filters', text: 'Other: Asiatic Indian')
    filters = Rack::Utils.parse_nested_query(URI.parse(page.current_url).query).fetch('s')
    expect(filters.fetch('race_in')).to eq(['Asiatic Indian', 'Portuguese'])
    click_button 'Add/edit filters'
    expect(all('[data-write-in]').map(&:value)).to eq(['Asiatic Indian', 'Portuguese'])
    all('button', text: 'Remove write-in').last.click
    find('[data-write-in]').set('Burmese')
    click_button 'Apply filters'
    expect(page).to have_css('#attribute-filters', text: 'Other: Burmese')
    expect(page).to have_no_css('#attribute-filters', text: 'Portuguese')
  end
end
