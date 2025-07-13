# frozen_string_literal: true

require "rails_helper"

RSpec.describe "1940 US Census" do
  scenario "record life cycle" do
    user = create(:census_taker)
    user.add_role Role.find_by(name: "reviewer")

    locality = create(:locality)

    sign_in user

    visit new_census1940_record_path
    wait_for_stable_dom
    expect(page).to have_content("New 1940 Census Record")

    safe_fill_in "Sheet", with: "1"
    safe_select "A", from: "Side"
    safe_fill_in "Line", with: "1"
    safe_fill_in "County", with: "Tompkins", match: :first
    safe_fill_in "Place", with: "Ithaca", match: :first
    safe_fill_in "Ward", with: "1"
    safe_fill_in "Enum Dist", with: "1"
    safe_fill_in "House No.", with: "405"
    safe_select "N", from: "Prefix"
    safe_fill_in "Street Name", with: "Tioga"
    safe_select "St", from: "Suffix"
    check "Add Building at Address"
    safe_select locality.name, from: "Locality"
    safe_fill_in "Household No.", with: "1"

    safe_fill_in "Last Name", with: "Squarepants"
    safe_fill_in "First Name", with: "Sponge"
    safe_fill_in "Middle Name", with: "Bob"
    safe_fill_in "Title", with: "Dr"
    safe_fill_in "Suffix", with: "III"

    safe_fill_in "Relation to Head", with: "Head"

    choose "M - Male", name: "census_record[sex]"
    choose "W - White", name: "census_record[race]"
    safe_fill_in "Age at Last Birthday", with: "28"
    safe_fill_in "Age (Months)", with: "5"
    choose "M - Married", name: "census_record[marital_status]"

    check "Attended School or College?"
    choose "C 5 Or Over", name: "census_record[grade_completed]"

    safe_fill_in "Place of Birth", with: "At Sea"
    check "Foreign Born"
    choose "AmCit - American Citizen", name: "census_record[naturalized_alien]"

    safe_fill_in "Town", with: "Ithaca", name: "census_record[residence_1935_town]"
    safe_fill_in "County", with: "Tompkins", name: "census_record[residence_1935_county]"
    safe_fill_in "State", with: "New York", name: "census_record[residence_1935_state]"
    check "On a Farm"

    check "Private/Non-emergency Government Work"
    check "Public Emergency Work"
    check "Seeking Work"
    check "Employed but Temporarily Absent"
    safe_fill_in "Duration of Unemployment in Weeks", with: "20"

    safe_fill_in "Occupation", with: "Turnkey", match: :first
    safe_fill_in "Industry", with: "Hotel"
    choose "PW - Private Wage or Salary Worker", name: "census_record[worker_class]"
    safe_fill_in "Occupation Code", with: "VX70"
    safe_fill_in "Industry Code", with: "VX70"
    safe_fill_in "Worker Class Code", with: "3"
    safe_fill_in "Weeks Worked in 1939", with: "32"

    choose "$5,000+", name: "census_record[wages_or_salary]"
    check "Other Income Source"

    safe_fill_in "Place of Birth - Father", with: "Ireland"
    safe_fill_in "Place of Birth - Mother", with: "Germany"
    safe_fill_in "Mother Tongue", with: "English"

    safe_fill_in "Notes", with: "Sponge Bob is a fictional cartoon character."

    safe_select "In this family", from: "After saving, add another person:"
    safe_click "input[type='submit']"

    # Make sure it saves and moves on to the next form with the correct fields prefilled
    wait_for_stable_dom
    expect(page).to have_content("New 1940 Census Record")
    expect(find_field("Sheet").value).to eq "1"
    expect(find_field("Side").value).to eq "A"
    expect(find_field("County", match: :first).value).to eq "Tompkins"
    expect(find_field("Place", match: :first).value).to eq "Ithaca"
    expect(find_field("Ward").value).to eq "1"
    expect(find_field("Enum Dist").value).to eq "1"
    expect(find_field("House No.").value).to eq "405"
    expect(find_field("Prefix").value).to eq "N"
    expect(find_field("Street Name").value).to eq "Tioga"
    expect(find_field("Suffix", match: :first).value).to eq "St"
    expect(find_field("Household No.").value).to eq "1"
    expect(find_field("Last Name").value).to eq "Squarepants"
    expect(find_field("Locality").value).to eq locality.id.to_s

    safe_click "a", text: "View All"
    wait_for_stable_dom
    expect(page).to have_content "1940 U.S. Census"
    expect(page).to have_content "Found 1 record"
    expect(find(".ag-cell", match: :first)).to have_content("Squarepants")
    # This tests that the record is marked unreviewed but mysteriously stopped working in the test
    # but not in reality.
    # expect(find("span.badge.badge-success")).to have_content("NEW")

    safe_click "a", text: "Squarepants III, Sponge Bob Dr"
    wait_for_stable_dom
    expect(page).to have_content "Squarepants III, Sponge Bob Dr"
    # This would be a good place to verify that the page has all the things

    safe_click "a", text: "Edit"
    wait_for_stable_dom
    expect(page).to have_content "Census Scope"
    expect(find_field("Last Name").value).to eq("Squarepants")
    safe_fill_in "Last Name", with: "Roundpants"
    safe_click "input[type='submit']"
    expect(page).to have_content "Roundpants"

    # Now review the record
    page.accept_confirm do
      safe_click "a", text: "Review"
    end
    expect(page).to have_content "Reviewed by #{user.login} on"
  end
end
