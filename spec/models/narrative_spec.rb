# == Schema Information
#
# Table name: narratives
#
#  id             :bigint           not null, primary key
#  created_by_id  :bigint           not null
#  reviewed_by_id :bigint
#  reviewed_at    :datetime
#  weight         :integer          default(0)
#  source         :string
#  notes          :text
#  date_type      :integer
#  date_text      :string
#  date_start     :date
#  date_end       :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_narratives_on_created_by_id   (created_by_id)
#  index_narratives_on_reviewed_by_id  (reviewed_by_id)
#
require 'rails_helper'

RSpec.describe Narrative, type: :model do
  let(:narrative) do
    described_class.new(created_by: create(:active_user),
                        story: '<p>A <strong>canal warehouse</strong></p>',
                        sources: '<p>City directory, 1910</p>')
  end

  it 'persists rich text and indexes its plain text for search' do
    narrative.save!
    narrative.reload

    expect(narrative.story.body.to_html).to include('<strong>canal warehouse</strong>')
    expect(narrative.sources.to_plain_text).to include('City directory, 1910')
    expect(described_class.full_text_search('warehouse')).to include(narrative)
    expect(narrative.searchable_text).not_to include('<strong>')
  end

  it 'updates the search index when the story changes' do
    narrative.save!
    narrative.update!(story: '<p>A railway station</p>')

    expect(described_class.full_text_search('railway')).to include(narrative)
    expect(described_class.full_text_search('warehouse')).not_to include(narrative)
  end

  it 'requires both the story and source citations' do
    narrative.story = ''
    narrative.sources = ''

    expect(narrative).not_to be_valid
    expect(narrative.errors[:story]).to be_present
    expect(narrative.errors[:sources]).to be_present
  end
end
