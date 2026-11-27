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
    find('#attribute-filters button[data-edit-scope="race_in"]').click
    expect(all('[data-write-in]').map(&:value)).to eq(['Asiatic Indian', 'Portuguese'])
    all('button', text: 'Remove write-in').last.click
    find('[data-write-in]').set('Burmese')
    click_button 'Apply filters'
    expect(page).to have_css('#attribute-filters', text: 'Other: Burmese')
    expect(page).to have_no_css('#attribute-filters', text: 'Portuguese')
  end

  scenario 'restores the latest 1950 write-in filter and columns from the Data menu', :js do
    sign_in create(:administrator)
    fields = %w[name race industry]
    visit census_records_path(year: 1950, s: { race_in: ['Burmese'] }, f: fields)

    expect(page).to have_css('#attribute-filters', text: 'Other: Burmese')
    find('#attribute-filters button[data-edit-scope="race_in"]').click
    find('[data-write-in]').set('Asiatic Indian')
    click_button 'Apply filters'
    expect(page).to have_css('#attribute-filters', text: 'Other: Asiatic Indian')

    visit root_path
    click_link 'Data', exact: true
    click_link '1950 US Census'

    expect(page).to have_css('#attribute-filters', text: 'Other: Asiatic Indian')
    restored = Rack::Utils.parse_nested_query(URI.parse(page.current_url).query)
    expect(restored.fetch('s').fetch('race_in')).to eq(['Asiatic Indian'])
    expect(restored.fetch('f')).to match_array(fields)
  end
end
