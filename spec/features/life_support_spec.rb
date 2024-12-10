# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Checking for life support' do
  scenario 'home page works' do
    visit root_path
    expect(page).to have_content('Welcome')
  end
end
