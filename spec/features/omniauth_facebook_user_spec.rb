# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Facebook Omni-Authentication' do

  # scenario 'facebook button exists' do
  #   settings = create(:setting)
  #   admin = create(:administrator)
  #   sign_in admin
  #   visit settings_path
  #   expect(page).to have_content(settings.group)
  #   check 'Enable Facebook Authentication'
  #   click_button 'Submit'
  #   visit root_path
  #   sign_out(admin)
  #   visit new_user_session_path
  #   expect(page).to have_content('Log in')
  #   expect(page).to have_css('#facebook_button')
  # end
  #
  # scenario 'create user facebook button' do
  #   valid_facebook_login_setup
  #   expect(User.first).to equal(nil)
  #   Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
  #   visit new_user_session_path
  #   find(:xpath, "//a/img[@id='facebook_button']/..").click
  #   expect(User.first.uid).to eq("123545")
  # end
  #
  # scenario 'facebook button does not exist' do
  #   settings = create(:setting)
  #   admin = create(:administrator)
  #   sign_in admin
  #   visit settings_path
  #   expect(page).to have_content(settings.group)
  #   check 'Enable Facebook Authentication'
  #   uncheck 'Enable Facebook Authentication'
  #   click_button 'Submit'
  #   visit root_path
  #   sign_out(admin)
  #   visit new_user_session_path
  #   expect(page).to have_content('Log in')
  #   expect(page).to have_no_css('#facebook_button')
  # end
end
