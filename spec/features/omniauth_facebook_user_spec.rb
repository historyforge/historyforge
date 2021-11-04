require 'rails_helper'

RSpec.describe 'Facebook Omni-Authenticaiton' do

  scenario 'facebook button exists' do
    settings = create(:setting)
    admin = create(:administrator)
    sign_in admin
    visit settings_path
    expect(page).to have_content(settings.group)
    check 'Enable Facebook Authentication'
    click_button 'Submit'
    visit root_path
    sign_out(admin)
    visit new_user_session_path
    expect(page).to have_content('Log in')
    expect(page).to have_css('#facebook_button')
  end

  # scenario 'facebook button does not exist' do
  #   create(:setting)
  #   visit new_user_session_path
  #   expect(page).to have_content('Log in')
  #   expect(page).to have_no_css('#facebook_button')
  # end
end
