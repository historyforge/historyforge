# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'people' do
  scenario 'edit people' do
    sign_in create(:administrator)
    person = create(:person, death_year: 1940, is_death_year_estimated: false)
    visit person_path(person.id)
    expect(page).to have_content 'First1 Last1'
    expect(page).to have_content '1940'
    click_on 'Edit'
    fill_in 'Birth Year', with: '1850'
    find(:checkbox, 'person_is_birth_year_estimated', checked: true)
    find(:checkbox, 'person_is_death_year_estimated', checked: false)
    fill_in 'Place of Birth', with: 'New Orleans'
    find(:checkbox, 'person_is_pob_estimated', checked: true)
    click_on 'Save', match: :first
    expect(page).to have_content '1850'
  end
end
