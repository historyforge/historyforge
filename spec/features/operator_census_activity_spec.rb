# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Operator census activity' do
  scenario 'opens a census grid filtered to the operator selected by login', :js do
    allow(Setting).to receive(:can_view_private?).and_call_original
    allow(Setting).to receive(:can_view_private?).with(1910).and_return(true)
    reviewer = create(:active_user)
    reviewer.add_role Role.find_by(name: 'reviewer')
    operator = create(:census_taker, login: 'canal_operator', full_name: 'Marisol Ruiz')
    create(:census1910_record, created_by: operator, reviewed_at: Time.current)
    create(:census1910_record, created_by: reviewer, reviewed_at: Time.current)
    sign_in reviewer

    within('#my-menu-item') do
      click_link 'My'
      click_link 'Operator census activity'
    end
    expect(page).to have_button('Show activity', disabled: true)
    fill_in 'Operator', with: 'canal_operator'
    expect(page).to have_css('[role="option"]', text: 'Marisol Ruiz (canal_operator)')
    find_field('Operator').send_keys(:arrow_down, :enter)
    click_button 'Show activity'

    within('table') do
      expect(page).to have_css('td', exact_text: '1')
      click_link '1910 US Census'
    end
    expect(page).to have_current_path(census_records_path(year: 1910, s: { creator_id: operator.id }))
    expect(page).to have_button('Created by Marisol Ruiz')
  end
end
