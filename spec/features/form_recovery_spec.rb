# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Correcting a rejected form', type: :feature do
  scenario 'a volunteer can add missing narrative citations and resubmit without losing the story' do
    sign_in create(:administrator)
    visit new_narrative_path
    find('trix-editor[input="narrative_story_trix_input_narrative"]').set('A warehouse beside the canal')
    original_count = Narrative.count
    click_button 'Submit'

    expect(page).to have_content("can't be blank")
    expect(Narrative.count).to eq(original_count)
    expect(find('trix-editor[input="narrative_story_trix_input_narrative"]')).to have_text('A warehouse beside the canal')
    find('trix-editor[input="narrative_sources_trix_input_narrative"]').set('City directory, 1910')
    click_button 'Submit'

    expect(page).to have_content('The Narrative has been uploaded and saved.')
    expect(Narrative.count).to eq(original_count + 1)
    narrative = Narrative.order(:id).last
    expect(narrative.story.to_plain_text).to include('A warehouse beside the canal')
    expect(narrative.sources.to_plain_text).to include('City directory, 1910')
  end
end
