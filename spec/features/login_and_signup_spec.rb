# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Checking for life support' do
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
  end
end
