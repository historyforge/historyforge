require 'rails_helper'

RSpec.describe '1900 US Census' do
  scenario 'record life cycle' do
    user = create(:census_taker)
    locality = create(:locality)

    sign_in user

    visit new_census1900_record_path
    expect(page).to have_content('New 1900 Census Record')

    fill_in 'Sheet', with: '1'
    select 'A', from: 'Side'
    fill_in 'Line', with: '1'
    fill_in 'County', with: 'Tompkins'
    fill_in 'City', with: 'Ithaca'
    fill_in 'Ward', with: '1'
    fill_in 'Enum dist', with: '1'
    fill_in 'House No.', with: '405'
    select 'N', from: 'Prefix'
    fill_in 'Street Name', with: 'Tioga'
    select 'St', from: 'Suffix'
    check 'Add building with address'
    select locality.name, from: 'Locality'
    fill_in 'Dwelling No.', with: '1'
    fill_in 'Family No.', with: '1'

    fill_in 'Last name', with: 'Squarepants'
    fill_in 'First name', with: 'Sponge'
    fill_in 'Middle name', with: 'Bob'
    fill_in 'Title', with: 'Dr'
    fill_in 'Suffix', with: 'III'

    fill_in 'Relation to head', with: 'Head'

    choose 'W - White', name: 'census_record[race]'
    choose 'M - Male', name: 'census_record[sex]'
    choose '8 - August', name: 'census_record[birth_month]'
    fill_in 'Birth year', with: '1872'
    fill_in 'Age', with: '28'
    fill_in 'Age (months)', with: '5'
    choose 'M - Married', name: 'census_record[marital_status]'
    fill_in 'Years of Present Marriage', with: '6'
    fill_in 'Num children born', with: '3'
    fill_in 'Num children alive', with: '1'

    fill_in 'Place of Birth', with: 'New York'
    fill_in 'Place of Birth - Father', with: 'Ireland'
    fill_in 'Place of Birth - Mother', with: 'Germany'

    fill_in 'Profession', with: 'Turnkey'
    fill_in 'Industry', with: 'Hotel'
    check 'Can Read?'
    check 'Can Write?'
    check 'Speaks English?'

    choose 'R - Rented', name: 'census_record[owned_or_rented]'
    choose 'H - House', name: 'census_record[farm_or_house]'

    select 'In this family', from: 'After saving, add another person:'
    click_on 'Save'
    record = Census1900Record.first
    expect(record.last_name).to eq('Squarepants')
    expect(record.reviewed?).to be_falsey
    expect(record.created_by).to eq user

    building = Building.first
    expect(building).to_not be_nil

    # Make sure it saves and moves on to the next form with the correct fields prefilled
    expect(page).to have_content('New 1900 Census Record')
    expect(find_field('Sheet').value).to eq '1'
    expect(find_field('Side').value).to eq 'A'
    expect(find_field('County').value).to eq 'Tompkins'
    expect(find_field('City').value).to eq 'Ithaca'
    expect(find_field('Ward').value).to eq '1'
    expect(find_field('Enum dist').value).to eq '1'
    expect(find_field('Dwelling No.').value).to eq '1'
    expect(find_field('House No.').value).to eq '405'
    expect(find_field('Prefix').value).to eq 'N'
    expect(find_field('Street Name').value).to eq 'Tioga'
    expect(find_field('Suffix').value).to eq 'St'
    expect(find_field('Family No.').value).to eq '1'
    expect(find_field('Building').value).to eq building.id.to_s
    expect(find_field('Last name').value).to eq 'Squarepants'
    expect(find_field('Locality').value).to eq locality.id.to_s

    click_link 'View All'
    expect(page).to have_content '1900 U.S. Census'
    expect(find('.ag-cell', match: :first)).to have_content('Squarepants')
    expect(find('span.badge.badge-danger')).to have_content('NEW')
    expect(page).to have_content 'Found 1 record'

    click_on 'View'
    expect(page).to have_content 'Squarepants, Sponge Bob'
    # This would be a good place to verify that the page has all the things

    click_on 'Edit'
    expect(page).to have_content 'Census Scope'
    expect(find_field('Last name').value).to eq('Squarepants')
    fill_in 'Last name', with: 'Roundpants'
    click_on 'Save', match: :first
    expect(page).to have_content 'Roundpants'

    # We are only a census taker. We can't review stuff.
    # expect(page).to have_no_content 'Mark as Reviewed'
    # expect(page).to have_no_content 'Delete'

    # Upgrade the user to Reviewer
    user.roles << Role.find_by(name: 'reviewer')
    visit census1900_record_path(record)

    # Now review the record
    expect(page).to have_css('.dropdown-item', text: 'Mark as Reviewed', visible: :hidden)
    click_on 'Actions'
    click_on 'Mark as Reviewed'
    expect(page).to have_content "Reviewed by #{user.login} on"
  end
end