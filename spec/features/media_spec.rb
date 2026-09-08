# frozen_string_literal: true

require 'rails_helper'
require 'tempfile'
require 'vips'

RSpec.describe 'Media editing', type: :feature do
  before { sign_in create(:administrator) }

  scenario 'upload a photograph through the wizard and retain the original' do
    Tempfile.create(['warehouse', '.jpg']) do |file|
      image = Vips::Image.black(20, 10).jpegsave_buffer
      file.binmode
      file.write(image)
      file.flush

      visit new_photograph_path
      attach_file 'Upload your photo', file.path
      expect(page).to have_css('#selected-file img')
      click_button 'Next »', match: :first
      fill_in 'Caption', with: 'Canal warehouse'
      # Advance through the optional wizard steps using the visible navigation.
      5.times { click_button 'Next »', match: :first }
      click_button 'Submit'
      expect(page).to have_content('The Photograph has been uploaded and saved.')
      photo = Photograph.order(:id).last
      expect(photo.caption).to eq('Canal warehouse')
      expect(photo.file.download).to eq(image)
      photo.file.purge
    end
  end

  scenario 'create and edit a narrative with rich text and source citations' do
    visit new_narrative_path
    find('trix-editor[input="narrative_story_trix_input_narrative"]', visible: true).set('A canal warehouse')
    find('trix-editor[input="narrative_sources_trix_input_narrative"]', visible: true).set('City directory, 1910')
    click_button 'Submit'
    expect(page).to have_content('The Narrative has been uploaded and saved.')
    narrative = Narrative.order(:id).last
    expect(narrative.story.to_plain_text).to include('A canal warehouse')
    visit edit_narrative_path(narrative)
    find('trix-editor', match: :first).set('A railway station')
    click_button 'Submit'
    expect(page).to have_content('The Narrative has been updated.')
    expect(narrative.reload.story.to_plain_text).to include('A railway station')
  end
end
