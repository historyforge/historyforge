# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Native autocomplete" do
  scenario "pasted searches support keyboard selection and reconnect after Turbo Back", :js do
    Cms::Page.create!(controller: "HomeController", action: "index", url_path: "/", title: "Home",
                     template: "{{ person_finder }} {{ home_finder }}")
    person = create(:person, first_name: "Beatrice", middle_name: nil, last_name: "Canal")
    building = create(:building, :reviewed, addresses: [build(:address, house_number: "92", name: "Foundry", prefix: nil, suffix: "St")])

    visit root_path
    expect(page.evaluate_script("typeof window.jQuery")).to eq("undefined")
    search = find("#search-people-input")
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
    find("#search-buildings-input").set("Foundry")
    find('[role="option"]', text: "92 Foundry St").click
    expect(page).to have_current_path(building_path(building))
  end

  scenario "a creator suggestion supplies the filter ID and editing clears it", :js do
    sign_in create(:administrator)
    creator = create(:active_user, login: "canal_reviewer")

    visit people_path
    click_button "Filter"
    lookup = find("#creator_lookup")
    lookup.set("ca")
    expect(page).to have_css('[role="option"]', text: "canal_reviewer")
    lookup.send_keys(:arrow_down, :enter)
    expect(page).to have_field("s[creator_id]", type: :hidden, with: creator.id.to_s)
    lookup.set("unselected")
    expect(page).to have_field("s[creator_id]", type: :hidden, with: "")
  end
end
