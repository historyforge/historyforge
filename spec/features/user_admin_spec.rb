# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User management" do
  scenario "not logged in sees nothing" do
    visit users_path
    expect(page).to have_content "Your session may have expired. Please sign in again."
  end

  scenario "census taker sees nothing" do
    sign_in create(:census_taker)
    visit users_path
    expect(page).to have_content "Sorry you do not have permission to do that"
  end

  scenario "administrator adds user" do
    admin = create(:administrator)
    sign_in admin
    visit users_path
    expect(page).to have_content("Users")
    click_on "Create User"
    expect(page).to have_content("Add New User")
    email = Faker::Internet.email
    login = Faker::FunnyName.name
    fill_in "Email", with: email
    fill_in "Username", with: login
    click_on "Submit"
    expect(page).to have_content("Showing User \"#{login}\"")
    expect(page).to have_content("An invitation email has been sent to #{email}.")
    expect(ActionMailer::Base.deliveries).to_not be_empty
    body = ActionMailer::Base.deliveries.last.text_part.body.decoded
    token = body.match(/invitation_token=([^\s]+)/)[1]
    user = User.find_by!(email:)

    # The recipient opens the invitation in their own browser, not the admin session.
    Capybara.using_session(:invitee) do
      visit "/u/invitation/accept?invitation_token=#{token}"
      expect(page).to have_content("Set your password")
      fill_in("Password", with: "b1g_sekrit")
      fill_in("Repeat password", with: "b1g_sekrit")
      click_on("Set my password")
      expect(page).to have_content("Welcome to HistoryForge. You are up and running.")
      expect(user.reload.invitation_accepted_at).to be_present
      expect(user).to be_enabled
    end

    Capybara.using_session(:returning_invitee) do
      visit new_user_session_path
      fill_in("Email", with: user.email)
      fill_in("Password", with: "b1g_sekrit")
      click_on("Volunteer Log In")
      expect(page).to have_no_content("Volunteer Log In")
    end
  end

  scenario "administrator uses filters on users page" do
    # add some users with various roles and such
    sign_in create(:administrator)
    visit users_path
    expect(page).to have_content("Users")

    # click on the filters and then search
    # verify that the page has a user that matches the filters and doesn't have a user that doesn't match
  end
end
