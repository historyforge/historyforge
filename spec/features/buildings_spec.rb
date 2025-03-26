# frozen_string_literal: true

require "rails_helper"

RSpec.describe "buildings" do
  # TODO: merge a building

  scenario "search buildings" do
    locality = create(:locality)
    create(:building, :reviewed, locality:, addresses: [build(:address, house_number: "405", name: "Tioga", prefix: "N", suffix: "St")])
    create(:building, :reviewed, locality:, addresses: [build(:address, house_number: "405", name: "Titus", prefix: "N", suffix: "Ave")])
    create(:building, :reviewed, locality:, addresses: [build(:address, house_number: "405", name: "Tioga", prefix: "S", suffix: "St")])
    create(:building, locality:, addresses: [build(:address, house_number: "405", name: "Cayuga", prefix: "N", suffix: "St")])

    visit buildings_path

    expect(page).to have_content "Buildings"
    expect(page).to have_content "Found 3 records"
    click_button "Filter"
    select "Street Address"
    select "contains"
    fill_in with: "405 N Titus"
    click_on "Submit"
    expect(page).to have_content "Found 1 record"
    # sleep 1 # Otherwise sometimes it says it can't find View
    expect(page).to have_content "405 N Titus Ave", wait: 5
    click_on "405 N Titus Ave"
    expect(page).to have_content "405 N Titus Ave"
  end

  scenario "edit buildings" do
    sign_in create(:builder)
    building = create(:building, addresses: [build(:address, house_number: "405", name: "Cayuga", prefix: "N", suffix: "St")])

    visit edit_building_path(building)
    # expect(page).to have_content '405 N Cayuga St'
    # click_on 'Edit'
    expect(page).to have_content building.name
    fill_in "Year Built", with: "1867"
    fill_in "Year Demolished", with: "1945"
    click_on "Save", match: :first
    expect(page).to have_content "1867"
    expect(page).to have_content "1945"
    click_on "Edit"
    expect(page).to have_no_content "Delete"
  end

  scenario "delete a building" do
    sign_in create(:administrator)
    building = create(:building, addresses: [build(:address, house_number: "405", name: "Cayuga", prefix: "N", suffix: "St")])

    visit edit_building_path(building)

    expect(page).to have_content building.name
    accept_confirm { click_link "Delete" }
    expect(page).to have_content "Building deleted"
  end

  scenario "add a building" do
    locality = create(:locality)
    sign_in create(:builder)
    visit buildings_path
    click_link "Add New Record"
    expect(page).to have_content "New Building"
    fill_in "Building Name", with: "The David Building"
    check "Commercial"
    fill_in "Year Built", with: "1949"
    fill_in with: "125", id: "building_addresses_attributes_0_house_number"
    select "N" #, id: 'building_addresses_attributes_0_prefix'
    fill_in with: "Cayuga", id: "building_addresses_attributes_0_name"
    select "St" #, id: 'building_addresses_attributes_0_suffix'
    fill_in with: "Ithaca", id: "building_addresses_attributes_0_city"
    select locality.name
    click_on "Save"
    expect(page).to have_content "The David Building"
  end
end
