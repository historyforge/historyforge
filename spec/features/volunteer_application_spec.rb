# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Volunteer application to user invitation', type: :feature do
  before { Cms::PageRenderer.compiled_templates = {} }
  after { Cms::PageRenderer.compiled_templates = {} }

  scenario 'an applicant submits the form, an admin invites them, and they accept and log in' do
    locality = create(:locality)
    admin = create(:administrator)
    Cms::Page.create!(title: 'Volunteer', url_path: '/volunteer',
                     template: '<p>Citizen historians wanted</p><a href="/volunteer_applications/new">Apply to volunteer</a>')
    email = 'new-volunteer@example.org'

    visit '/volunteer'
    click_link 'Apply to volunteer'
    fill_in 'Name (First Name Last Name)', with: 'Alex Historian'
    fill_in 'Email address', with: email
    fill_in 'How did you hear about HistoryForge?', with: 'The library'
    check locality.name
    check 'Working with historic maps'
    check 'Other', exact: true
    fill_in 'Other — please describe', with: 'Local history walks'
    choose 'Maybe'
    expect(page).to have_no_content('Un - Unknown')
    expect(page).to have_no_content('Left blank')
    fill_in 'Please explain:', with: 'I have scanned historic maps.'
    click_button 'Submit application'
    expect(page).to have_content('Your volunteer application has been received')
    application = VolunteerApplication.find_by!(email: email)
    expect(application.locality_names).to eq([locality.name])
    expect(application.opportunity_interests).to contain_exactly('maps', 'other')
    expect(application.user).to be_nil

    sign_in admin
    visit volunteer_applications_path
    click_link 'Alex Historian'
    expect(page).to have_content('Working with historic maps')
    expect(page).to have_content('Local history walks')
    select 'Contacted', from: 'Status'
    fill_in 'Staff notes (only visible to administrators)', with: 'Ready to invite'
    click_button 'Save follow-up'
    expect(page).to have_content('Application updated.')
    click_link 'Create / connect user'
    expect(page).to have_field('Username', with: 'Alex Historian')
    click_button 'Create user and send invitation'
    expect(page).to have_content("An invitation email has been sent to #{email}.")
    user = application.reload.user
    expect(user.full_name).to eq('Alex Historian')
    expect(application.status).to eq('contacted')
    expect(user).not_to be_enabled
    mail = ActionMailer::Base.deliveries.find { |message| message.to.include?(email) }
    token = (mail.text_part || mail).body.decoded.match(/invitation_token=([^\s]+)/)[1]

    Capybara.using_session(:volunteer_acceptance) do
      visit "/u/invitation/accept?invitation_token=#{token}"
      fill_in 'Password', with: 'b1g_sekrit'
      fill_in 'Repeat password', with: 'b1g_sekrit'
      click_button 'Set my password'
      expect(page).to have_content('Welcome to HistoryForge. You are up and running.')
      expect(user.reload.invitation_accepted_at).to be_present
      expect(user).to be_enabled
    end

    Capybara.using_session(:volunteer_login) do
      visit new_user_session_path
      fill_in 'Email', with: email
      fill_in 'Password', with: 'b1g_sekrit'
      click_button 'Volunteer Log In'
      expect(page).to have_no_button('Volunteer Log In')
      dismiss_passkey_prompt
      find('#user-menu-item > a').click
      expect(page).to have_css('#user-name', text: 'Alex Historian')
    end
  end
end
