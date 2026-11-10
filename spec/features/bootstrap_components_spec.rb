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
    hint = first("[data-bs-toggle=popover]")
    page.execute_script("arguments[0].focus()", hint)
    expect(page).to have_css(".popover.show", count: 1)

    page.execute_script("Turbo.visit(arguments[0])", buildings_path)
    expect(page).to have_current_path(buildings_path, ignore_query: true)
    expect(page).to have_no_css(".popover", visible: :all)

    page.execute_script("Turbo.visit(arguments[0])", new_census1880_record_path)
    expect(page).to have_current_path(new_census1880_record_path)
    expect(page.evaluate_script("window.bootstrapTestVisit")).to be true
    expect(page).to have_css("[data-bs-toggle=popover]")
    page.execute_script("arguments[0].focus()", first("[data-bs-toggle=popover]"))
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
