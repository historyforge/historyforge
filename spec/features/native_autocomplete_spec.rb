# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Native autocomplete" do
  scenario "existing CMS search inputs support paste, keyboard selection, and Turbo Back", :js do
    Cms::Page.create!(controller: "HomeController", action: "index", url_path: "/", title: "Home", template: <<~HTML)
      <input type="search" id="search-people-input" placeholder="Type a name here" class="form-control">
      <input type="search" id="search-buildings-input" placeholder="Type an address here" class="form-control">
    HTML
    person = create(:person, first_name: "Beatrice", middle_name: nil, last_name: "Canal")
    building = create(:building, :reviewed, addresses: [build(:address, house_number: "92", name: "Foundry", prefix: nil, suffix: "St")])

    visit root_path
    expect(page.evaluate_script("typeof window.jQuery")).to eq("undefined")
    search = find(%q(#search-people-input[role="combobox"]))
    page.execute_script(<<~JS, search)
      arguments[0].focus()
      arguments[0].value = 'Canal'
      arguments[0].dispatchEvent(new InputEvent('input', { inputType: 'insertFromPaste', bubbles: true }))
    JS
    expect(page).to have_css('[role="option"]', text: /Beatrice.*Canal/)
    search.send_keys(:arrow_down, :enter)
    expect(page).to have_current_path(person_path(person))

    page.go_back
    expect(page).to have_current_path(root_path)
    expect(page).to have_no_css('.autocomplete-suggestions:not([hidden])')
    find(%q(#search-buildings-input[role="combobox"])).set("Foundry")
    find('[role="option"]', text: "92 Foundry St").click
    expect(page).to have_current_path(building_path(building))
  end
end
