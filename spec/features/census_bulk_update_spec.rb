# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bulk updates of census records' do
  scenario 'happy path' do
    user = create(:administrator)
    locality = create(:locality)
    sign_in user

    3.times do
      create(:census1920_record, locality: locality)
    end

    visit '/census/1920'
    click_on 'Bulk Update'
    expect(page).to have_content('Bulk Updates for 1920')
    expect(page).to have_content('None yet!')
    click_on 'Care to start?'
    expect(page).to have_content 'Start Bulk Update For 1920'
    select 'Family No.', from: 'Field'
    click_on 'Select Field'
    fill_in 'From', with: '1'
    fill_in 'To', with: '2'
    click_on 'Submit'
    expect(page).to have_content('Finalize Bulk Update for 1920')
    expect(page).to have_content "I hereby solemnly swear that I, #{user.name}, understand the consequences of changing these 3 records."
    check 'Confirm that you want to update 3 records.'
    click_on 'Submit'
    expect(page).to have_content('Family No. changed from 1 to 2.')
    expect(page).to have_content('3 Records affected:')
    expect(Census1920Record.where(family_id: 1).count).to eq(0)
    expect(Census1920Record.where(family_id: 2).count).to eq(3)
  end
end
