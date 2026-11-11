# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The Forge" do
  scenario "filters 1940 wages by a dollar amount or a special code", :js do
    user = create(:census_taker)
    sign_in user
    locality = create(:locality)
    %w[900 1000 5000+].each do |value|
      building = create(:building, :reviewed, locality:)
      create(:census1940_record, building:, locality:, wages_or_salary: value,
             reviewed_at: Time.current, reviewed_by: user)
    end

    visit forge_path
    find("#forge-sidebar-right-toggle", wait: 10).click
    find("select", text: "Select a year to search").find("option", text: "1940", exact_text: true).select_option
    find("option[value=wages_or_salary_amount]").select_option

    within(".modal.show") do
      choose "less than", exact: true
      find("input[type=number]").set("1000")
      click_button "Search"
    end
    expect(page).to have_content("Found 1 person in 1 building.")

    find(".list-group-item", text: "(amount in dollars)").find("span.float-right").click
    expect(page).to have_content("Found 3 people in 3 buildings.")
    find("option[value=wages_or_salary]").select_option

    within(".modal.show") do
      check "$5,000+"
      click_button "Search"
    end
    expect(page).to have_content("Found 1 person in 1 building.")
  end

  scenario "filters census buildings and opens the matching building details", :js do
    user = create(:census_taker)
    sign_in user
    building = create(:building, :reviewed, addresses: [build(:address, house_number: "92", prefix: nil, name: "Foundry", suffix: "St")])
    other_building = create(:building, :reviewed, locality: building.locality, lat: 42.444, lon: -76.492)
    [
      [building, "Foundry", 1],
      [other_building, "Railway", 2]
    ].each do |home, surname, line|
      create(:census1880_record, building: home, locality: home.locality, first_name: "Beatrice",
             last_name: surname, family_id: line.to_s, occupation: "Carpenter", page_number: 1,
             page_side: "A", line_number: line, county: "Tompkins", state: "New York",
             relation_to_head: "Head", sex: "F", race: "W", enum_dist: "1", reviewed_at: Time.current, reviewed_by: user)
    end

    visit forge_path
    find("#forge-sidebar-right-toggle", wait: 10).click
    find("select", text: "Select a year to search").find("option", text: "1880", exact_text: true).select_option
    find("select", text: "Select a field to search").find("option", text: "Last Name", exact_text: true).select_option

    within(".modal.show") do
      find("input[type=text]").set("Foundry")
      click_button "Search"
    end

    expect(page).to have_content("Found 1 person in 1 building.")
    find("#map .leaflet-overlay-pane path.leaflet-interactive").click
    within(".modal.show", text: "Building Details") do
      expect(page).to have_link("92 Foundry St", href: building_path(building))
      expect(page).to have_content("Foundry, Beatrice")
    end
  end

  scenario "toggles the Ithaca Sanborn overlay and changes its Leaflet opacity", :js do
    name = "1888 Sanborn Fire Insurance Atlas of Ithaca"
    endpoint = "https://maps.historyforge.net/mosaics/wms/185"
    MapOverlay.create!(name: name, year_depicted: 1888, active: true,
           url: "#{endpoint}?request=GetCapabilities&service=WMS&version=1.1.1")

    visit forge_path
    find("#forge-sidebar-left-toggle", wait: 10).click
    check name
    pane = "#map .leaflet-historicalMaps-pane"
    expect(page).to have_css(%(#{pane} img[src^="#{endpoint}?"][src*="GetMap"]), visible: :all)

    within("#forge-left-col .layer", text: name) do
      find("input[type=range]").send_keys(:left)
    end
    expect(page).to have_css(%(#{pane} .leaflet-layer[style*="opacity: 0.99"]), visible: :all)

    uncheck name
    expect(page).to have_no_css("#{pane} .leaflet-layer", visible: :all)
  end

  scenario "filters by blank and populated institution names without a text input", :js do
    user = create(:census_taker)
    sign_in user
    locality = create(:locality)
    [nil, "", "County Almshouse"].each_with_index do |name, index|
      building = create(:building, :reviewed, locality:)
      create(:census1850_record, building:, locality:, page_number: 1, line_number: index + 1,
             county: "Tompkins", state: "New York", first_name: "John", last_name: "Doe",
             family_id: (index + 1).to_s, occupation: "None", institution_name: name, sex: "M", race: "W",
             reviewed_at: Time.current, reviewed_by: user)
    end

    visit forge_path
    find("#forge-sidebar-right-toggle", wait: 10).click
    find("select", text: "Select a year to search").find("option", text: "1850", exact_text: true).select_option
    find("select", text: "Select a field to search").find("option", text: "Institution Name", exact_text: true).select_option

    within(".modal.show") do
      choose "is blank"
      expect(page).to have_no_css("input[type=text]")
      click_button "Search"
    end
    expect(page).to have_content("Found 2 people in 2 buildings.")

    find(".list-group-item", text: "Institution Name is blank").click
    within(".modal.show") do
      choose "is not blank"
      expect(page).to have_no_css("input[type=text]")
      click_button "Search"
    end
    expect(page).to have_content("Found 1 person in 1 building.")
  end
end
