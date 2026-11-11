# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Bootstrap components" do
  scenario "navigation, the passkey prompt, and census hints work through Turbo visits", :js do
    login_as(create(:administrator), scope: :user)
    create(:locality)

    visit root_path
    expect(page).to have_css("#passkeyPromptModal.show")
    click_button "Not now"
    expect(page).to have_no_css(".modal-backdrop")

    page.execute_script("window.bootstrapTestVisit = true")
    within("#main-header") do
      click_link "Data"
      click_link "Buildings"
    end
    expect(page).to have_current_path(buildings_path)
    expect(page.evaluate_script("window.bootstrapTestVisit")).to be true
    expect(page).to have_no_css("#passkeyPromptModal.show")

    find(%q(button[data-bs-target="#fieldSelector"]), match: :first).click
    expect(page).to have_css("#fieldSelector.show")
    within("#fieldSelector") { find(%q(button[aria-label="Close"])).click }
    expect(page).to have_no_css("#fieldSelector.show")

    find('label[for="scope_unpeopled"]').click
    expect(page).to have_current_path(/scope=unpeopled/)

    page.execute_script("Turbo.visit(arguments[0])", new_census1880_record_path)
    expect(page).to have_current_path(new_census1880_record_path)
    expect(page).to have_css("[data-bs-toggle=popover]")
    find_field("Institution", exact: true).send_keys(:tab)
    last_name = find("#census_record_last_name:focus")
    expect(page).to have_no_css(".popover.show")
    last_name.send_keys(:f1)
    expect(page).to have_css(".popover.show", count: 1)

    last_name.send_keys(:escape)
    expect(page).to have_no_css(".popover.show")
    last_name.send_keys(:tab)
    expect(page).to have_css("#census_record_first_name:focus")

    page.execute_script("Turbo.visit(arguments[0])", buildings_path)
    expect(page).to have_current_path(buildings_path, ignore_query: true)
    expect(page).to have_no_css(".popover", visible: :all)

    page.execute_script("Turbo.visit(arguments[0])", new_census1880_record_path)
    expect(page).to have_current_path(new_census1880_record_path)
    expect(page.evaluate_script("window.bootstrapTestVisit")).to be true
    expect(page).to have_css("[data-bs-toggle=popover]")
    find("#census_record_last_name").send_keys(:f1)
    expect(page).to have_css(".popover.show", count: 1)
  end

  scenario "the Forge closes its filter dialog when dismissed or when leaving the page", :js do
    sign_in create(:census_taker)

    visit forge_path
    find("#forge-sidebar-right-toggle", wait: 10).click
    find("select", text: "Select a year to search").find("option", text: "1880", exact_text: true).select_option
    find("select", text: "Select a field to search").find("option", text: "Last Name", exact_text: true).select_option

    dialog = find(".modal.show", text: "Last Name")
    dialog.find(%q(button[aria-label="Close"])).click
    expect(page).to have_no_css(".modal-backdrop")

    find("#forge-right-col .list-group-item", text: "Last Name").click
    expect(page).to have_css(".modal.show", text: "Last Name")
    page.execute_script("Turbo.visit(arguments[0])", root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_no_css(".modal-backdrop")
    expect(page).to have_no_css("body.modal-open")
  end
end
