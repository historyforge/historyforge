# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Password login and signup' do
  scenario 'login page with unsuccessful login' do
    visit new_user_session_path
    expect(page).to have_content('Volunteer Log In')
    fill_in 'Email', with: 'foo@bar.com'
    fill_in 'Password', with: 'big_sekrit'
    click_on 'Log In'
    expect(page).to have_content('Email')
    expect(page).to have_content('Password')
    expect(page).to have_content('Volunteer Log In')
  end

  scenario 'login page with successful login' do
    user = create(:active_user)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'b1g_sekrit'
    click_on 'Volunteer Log In'
    expect(page).to have_no_content('Volunteer Log In')
  end

  scenario 'user can register' do
    user = build(:active_user)
    visit new_user_session_path
    click_on 'Sign up'
    fill_in 'Username', with: user.login
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'b1g_sekrit'
    fill_in 'Repeat password', with: 'b1g_sekrit'
    click_on 'Sign Up'
    expect(page).to have_content('Welcome! You have signed up successfully.')
    registered_user = User.find_by!(email: user.email)
    expect(registered_user.valid_password?('b1g_sekrit')).to be(true)
    expect(registered_user.passkeys).to be_empty
  end
end
