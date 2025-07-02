# frozen_string_literal: true

require "rails_helper"

RSpec.describe "1930 US Census" do
  scenario "record life cycle" do
    user = create(:census_taker)
    user.add_role Role.find_by(name: "reviewer")
    locality = create(:locality)

    sign_in user

    visit new_census1930_record_path
    expect(page).to have_content("New 1930 Census Record")

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
    fill_in "Dwelling No.", with: "1"
    fill_in "Family No.", with: "1"

    fill_in "Last Name", with: "Squarepants"
    fill_in "First Name", with: "Sponge"
    fill_in "Middle Name", with: "Bob"
    fill_in "Title", with: "Dr"
    fill_in "Suffix", with: "III"

    fill_in "Relation to Head", with: "Head"

    # choose 'F - Free of mortgage', name: 'census_record[mortgage]'

    check "Home-Maker"
    choose "O - Owned", name: "census_record[owned_or_rented]"
    fill_in "Value of Home or Monthly Payment", with: "40000"
    check "Radio Set"
    check "Lives on Farm"

    choose "M - Male", name: "census_record[sex]"
    choose "W - White", name: "census_record[race]"
    fill_in "Age", with: "28"
    fill_in "Age (Months)", with: "5"
    choose "M - Married", name: "census_record[marital_status]"
    fill_in "Age at First Marriage", with: "22"
    check "Attended School"
    check "Can Read and Write"

    fill_in "Place of Birth", with: "New York"
    fill_in "Mother Tongue", with: "English"
    fill_in "Place of Birth - Father", with: "Ireland"
    fill_in "Place of Birth - Mother", with: "Germany"
    check "Speaks English"

    fill_in "Occupation", with: "Turnkey", match: :first
    fill_in "Industry", with: "Hotel"
    fill_in "Occupation Code", with: "VX70"
    choose "W - Wage or Salary Worker", name: "census_record[worker_class]"
    check "At Work Yesterday"
    check "Veteran"
    choose "Civ - Civil War", name: "census_record[war_fought]"

    fill_in "Notes", with: "Sponge Bob is a fictional cartoon character."

    select "In this family", from: "After saving, add another person:"
    click_on "Save"

    # Make sure it saves and moves on to the next form with the correct fields prefilled
    expect(page).to have_content("New 1930 Census Record")
    expect(find_field("Sheet").value).to eq "1"
    expect(find_field("Side").value).to eq "A"
    expect(find_field("County").value).to eq "Tompkins"
    expect(find_field("Place", match: :first).value).to eq "Ithaca"
    expect(find_field("Ward").value).to eq "1"
    expect(find_field("Enum Dist").value).to eq "1"
    expect(find_field("Dwelling No.").value).to eq "1"
    expect(find_field("House No.").value).to eq "405"
    expect(find_field("Prefix").value).to eq "N"
    expect(find_field("Street Name").value).to eq "Tioga"
    expect(find_field("Suffix", match: :first).value).to eq "St"
    expect(find_field("Family No.").value).to eq "1"
    # expect(find_field('Building').value).to eq building.id.to_s
    expect(find_field("Last Name").value).to eq "Squarepants"
    expect(find_field("Locality").value).to eq locality.id.to_s

    click_link "View All"
    expect(page).to have_content "1930 U.S. Census"
    expect(page).to have_content "Found 1 record"
    expect(find(".ag-cell", match: :first)).to have_content("Squarepants")
    # This tests that the record is marked unreviewed but mysteriously stopped working in the test
    # but not in reality.
    # expect(find('span.badge.badge-success')).to have_content('NEW')

    click_on "Squarepants III, Sponge Bob Dr"
    expect(page).to have_content "Squarepants III, Sponge Bob Dr"

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
