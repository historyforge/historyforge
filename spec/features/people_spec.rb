# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'people' do
  scenario 'a public census summary links only to readable census records', driver: :rack_test do
    person = create(:person)
    unreviewed_record = create(:census1920_record, person:, age: 50, pob: 'Pennsylvania')
    public_record = create(:census1910_record, person:, age: 30, pob: 'New York', street_name: 'Coddington',
                           street_suffix: 'Rd', reviewed_at: Time.current)
    hidden_record = create(:census1930_record, person:, age: 60, pob: 'Pennsylvania', reviewed_at: Time.current)
    allow(Setting).to receive(:can_view_public?).and_call_original
    allow(Setting).to receive(:can_view_public?).with(1930).and_return(false)

    visit person_path(person)

    expect(page).to have_no_text('Census Summary')
    expect(page).to have_no_css('h2', text: /\A(?:About|Person details)\z/i)
    within('.content-header .pills') do
      expect(page).to have_link('View All', href: people_path)
    end
    expect(page).to have_no_css('.person-actions')
    expect(page).to have_css('.col-lg-4 .card table[aria-label="Person details"]')
    within('section[aria-label="Biography"]') do
      expect(page).to have_text('lived on Coddington Rd')
      expect(page).to have_link('1910 census', href: polymorphic_path(public_record))
      expect(page).to have_no_link(href: polymorphic_path(unreviewed_record))
      expect(page).to have_no_link(href: polymorphic_path(hidden_record))
      expect(page).to have_no_text('Pennsylvania')
    end
  end

  scenario 'keeps the facts visible without generating an About paragraph for sparse records', driver: :rack_test do
    person = create(:person, birth_year: 1933)

    visit person_path(person)

    expect(page).to have_no_css('section[aria-label="Biography"]')
    within('table[aria-label="Person details"]') do
      expect(page).to have_css('th', text: 'Born')
      expect(page).to have_css('td', text: 'About 1933')
    end
  end

  scenario 'edit people' do
    sign_in create(:administrator)
    person = create(:person, death_year: 1940, is_death_year_estimated: false)
    visit person_path(person.id)
    expect(page).to have_content person.name
    expect(page).to have_content '1940'
    expect(page).to have_no_css('.content-header .pills', text: 'View All')
    within('.person-actions') do
      expect(page).to have_link('View All', href: people_path)
      click_on 'Edit'
    end
    fill_in 'Birth Year', with: '1850'
    find(:checkbox, 'person_is_birth_year_estimated', checked: true)
    find(:checkbox, 'person_is_death_year_estimated', checked: false)
    fill_in 'Place of Birth', with: 'New Orleans'
    find(:checkbox, 'person_is_pob_estimated', checked: true)
    click_on 'Save', match: :first
    expect(page).to have_content '1850'
  end
end
