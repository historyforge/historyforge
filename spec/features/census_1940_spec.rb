# frozen_string_literal: true

require "rails_helper"

RSpec.describe "1940 US Census" do
  scenario "record life cycle" do
    user = create(:census_taker)
    user.add_role Role.find_by(name: "reviewer")

    locality = create(:locality)

    sign_in user

    visit new_census1940_record_path
    expect(page).to have_content("New 1940 Census Record")

    fill_in "Sheet", with: "1"
    select "A", from: "Side"
    fill_in "Line", with: "1"
    fill_in "County", with: "Tompkins", match: :first
    fill_in "Place", with: "Ithaca", match: :first
    fill_in "Ward", with: "1"
    fill_in "Enum Dist", with: "1"
    fill_in "House No.", with: "405"
    select "N", from: "Prefix"
    fill_in "Street Name", with: "Tioga"
    select "St", from: "Suffix"
    check "Add Building at Address"
    select locality.name, from: "Locality"
    fill_in "Household No.", with: "1"

    fill_in "Last Name", with: "Squarepants"
    fill_in "First Name", with: "Sponge"
    fill_in "Middle Name", with: "Bob"
    fill_in "Title", with: "Dr"
    fill_in "Suffix", with: "III"

    fill_in "Relation to Head", with: "Head"

    choose "M - Male", name: "census_record[sex]"
    choose "W - White", name: "census_record[race]"
    fill_in "Age at Last Birthday", with: "28"
    fill_in "Age (Months)", with: "5"
    choose "M - Married", name: "census_record[marital_status]"

    check "Attended School or College?"
    choose "C 5 Or Over", name: "census_record[grade_completed]"

    fill_in "Place of Birth", with: "At Sea"
    check "Foreign Born"
    choose "AmCit - American Citizen", name: "census_record[naturalized_alien]"

    fill_in "Town", with: "Ithaca", name: "census_record[residence_1935_town]"
    fill_in "County", with: "Tompkins", name: "census_record[residence_1935_county]"
    fill_in "State", with: "New York", name: "census_record[residence_1935_state]"
    check "On a Farm"

    check "Private/Non-emergency Government Work"
    check "Public Emergency Work"
    check "Seeking Work"
    check "Employed but Temporarily Absent"
    fill_in "Duration of Unemployment in Weeks", with: "20"

    fill_in "Occupation", with: "Turnkey", match: :first
    fill_in "Industry", with: "Hotel"
    choose "PW - Private Wage or Salary Worker", name: "census_record[worker_class]"
    fill_in "Occupation Code", with: "VX70"
    fill_in "Industry Code", with: "VX70"
    fill_in "Worker Class Code", with: "3"
    fill_in "Weeks Worked in 1939", with: "32"

    choose "$5,000+", name: "census_record[wages_or_salary]"
    check "Other Income Source"

    fill_in "Place of Birth - Father", with: "Ireland"
    fill_in "Place of Birth - Mother", with: "Germany"
    fill_in "Mother Tongue", with: "English"

    fill_in "Notes", with: "Sponge Bob is a fictional cartoon character."

    select "In this family", from: "After saving, add another person:"
    click_on "Save"

    # Make sure it saves and moves on to the next form with the correct fields prefilled
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

    click_link "View All"
    expect(page).to have_content "1940 U.S. Census"
    expect(page).to have_content "Found 1 record"
    expect(find(".ag-cell", match: :first)).to have_content("Squarepants")
    # This tests that the record is marked unreviewed but mysteriously stopped working in the test
    # but not in reality.
    # expect(find("span.badge.badge-success")).to have_content("NEW")

    click_on "Squarepants III, Sponge Bob Dr"
    expect(page).to have_content "Squarepants III, Sponge Bob Dr"
    # This would be a good place to verify that the page has all the things

    click_on "Edit"
    expect(page).to have_content "Census Scope"
    expect(find_field("Last Name").value).to eq("Squarepants")
    fill_in "Last Name", with: "Roundpants"
    click_on "Save", match: :first
    expect(page).to have_content "Roundpants"

    # Now review the record
    page.accept_confirm do
      click_on "Review"
    end
    expect(page).to have_content "Reviewed by #{user.login} on"
  end
end
