# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Checking for life support" do
  scenario "login page with unsuccessful login" do
    visit new_user_session_path
    wait_for_stable_dom
    expect(page).to have_content("Volunteer Log In")
    safe_fill_in "Email", with: "foo@bar.com"
    safe_fill_in "Password", with: "big_sekrit"
    safe_click 'input[type="submit"]'
    expect(page).to have_content("Email")
    expect(page).to have_content("Password")
    expect(page).to have_content("Volunteer Log In")
  end

  scenario "login page with successful login" do
    user = create(:active_user)
    visit new_user_session_path
    wait_for_stable_dom
    safe_fill_in "Email", with: user.email
    safe_fill_in "Password", with: "b1g_sekrit"
    safe_click 'input[type="submit"]'
    expect(page).to have_no_content("Volunteer Log In")
  end

  scenario "user can register" do
    user = build(:active_user)
    visit new_user_session_path
    wait_for_stable_dom
    safe_click "a", text: "Sign up"
    wait_for_stable_dom
    safe_fill_in "Username", with: user.login
    safe_fill_in "Email", with: user.email
    safe_fill_in "Password", with: "b1g_sekrit"
    safe_fill_in "Repeat password", with: "b1g_sekrit"
    safe_click 'input[type="submit"]'
    expect(page).to have_content("Welcome! You have signed up successfully.")
  end
end
