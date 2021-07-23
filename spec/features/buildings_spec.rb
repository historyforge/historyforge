# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'buildings' do
  # TODO: merge a building

  scenario 'search buildings' do
    create(:building, :reviewed, addresses: [build(:address, house_number: '405', name: 'Tioga', prefix: 'N', suffix: 'St')])
    create(:building, :reviewed, addresses: [build(:address, house_number: '405', name: 'Titus', prefix: 'N', suffix: 'Ave')])
    create(:building, :reviewed, addresses: [build(:address, house_number: '405', name: 'Tioga', prefix: 'S', suffix: 'St')])
    create(:building, addresses: [build(:address, house_number: '405', name: 'Cayuga', prefix: 'N', suffix: 'St')])

    visit buildings_path
    expect(page).to have_content 'Buildings'
    expect(page).to have_content 'Found 3 records'
    click_button 'Filter'
    select 'Street address'
    select 'starts with'
    fill_in with: '405 N Titus'
    click_on 'Submit'
    expect(page).to have_content 'Found 1 record'
    # sleep 1 # Otherwise sometimes it says it can't find View
    expect(page).to have_content '405 N Titus Ave', wait: 5
    click_on 'View'
    expect(page).to have_content '405 N Titus Ave'
  end

  scenario 'edit buildings' do
    sign_in create(:builder)
    building = create(:building, addresses: [build(:address, house_number: '405', name: 'Cayuga', prefix: 'N', suffix: 'St')])

    visit building_path(building)
    expect(page).to have_content '405 N Cayuga St'
    click_on 'Edit'
    expect(page).to have_content building.name
    fill_in 'Year Built', with: '1867'
    fill_in 'Year Demolished', with: '1945'
    click_on 'Save', match: :first
    expect(page).to have_content 'Built in 1867. Torn down in 1945.'
    click_on 'Edit'
    expect(page).to have_no_content 'Delete'
  end

  scenario 'delete a building' do
    sign_in create(:administrator)
    building = create(:building, addresses: [build(:address, house_number: '405', name: 'Cayuga', prefix: 'N', suffix: 'St')])

    visit edit_building_path(building)

    expect(page).to have_content building.name
    accept_confirm { click_link 'Delete' }
    expect(page).to have_content 'Building deleted'
  end

  scenario 'add a building' do
    sign_in create(:builder)
    visit buildings_path
    click_link 'Add New Record'
    expect(page).to have_content 'New Building'
    fill_in 'Building Name', with: 'The David Building'
    check 'commercial'
    fill_in 'Year Built', with: '1949'
    check 'Year earliest circa'
    fill_in 'City', with: 'Ithaca', name: 'building[city]'
    fill_in 'State', with: 'New York'
    fill_in 'Postal code', with: '14850'
    fill_in with: '125', id: 'building_addresses_attributes_0_house_number'
    select 'N' #, id: 'building_addresses_attributes_0_prefix'
    fill_in with: 'Cayuga', id: 'building_addresses_attributes_0_name'
    select 'St' #, id: 'building_addresses_attributes_0_suffix'
    fill_in with: 'Ithaca', id: 'building_addresses_attributes_0_city'
    click_on 'Save'
    expect(page).to have_content 'The David Building'
  end
end
