require 'rails_helper'

RSpec.describe 'Checking for life support' do
  scenario 'hello world' do
    visit root_path
    expect(page).to have_content('Welcome')
  end

  scenario 'login page with unsuccessful login' do
    visit new_user_session_path
    expect(page).to have_content('Log in')
    fill_in 'Email', with: 'foo@bar.com'
    fill_in 'Password', with: 'big_sekrit'
    click_on 'Log in'
    expect(page).to have_content('Email')
    expect(page).to have_content('Password')
    expect(page).to have_content('Log in')
  end

  scenario 'login page with successful login' do
    user = create(:active_user)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'b1g_sekrit'
    click_on 'Log in'
    expect(page).to have_no_content('Log in')
    expect(page).to have_content(user.login)
  end
end
