require 'rails_helper'

RSpec.describe 'User management' do
  scenario 'not logged in sees nothing' do
    visit users_path
    expect(page).to have_content 'Sorry you do not have permission to do that'
  end

  scenario 'census taker sees nothing' do
    sign_in create(:census_taker)
    visit users_path
    expect(page).to have_content 'Sorry you do not have permission to do that'
  end

  scenario 'admininistrator adds user' do
    sign_in create(:administrator)
    visit users_path
    expect(page).to have_content('Users')
    click_on 'Create User'
    expect(page).to have_content('Send invitation')
    email = Faker::Internet.safe_email
    fill_in 'Email', with: email
    fill_in 'Username', with: Faker::FunnyName.name
    click_on 'Send an invitation'
    expect(page).to have_content "An invitation email has been sent to #{email}."
    expect(ActionMailer::Base.deliveries).to_not be_empty
    expect(page).to have_content 'Users'
  end
end
