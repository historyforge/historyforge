# frozen_string_literal: true

RSpec.shared_examples 'searchable reviewed media' do
  let(:creator) { create(:active_user) }
  let(:media) { described_class.create!(created_by: creator, caption: 'Canal warehouse') }

  it 'persists a caption and exposes it through the title and name aliases' do
    expect(media.reload.title).to eq('Canal warehouse')
    expect(media.name).to eq('Canal warehouse')
    expect(described_class.full_text_search('warehouse')).to include(media)
  end

  it 'records who reviewed it and does not overwrite an existing review' do
    reviewer = create(:active_user)
    media.review!(reviewer)
    reviewed_at = media.reload.reviewed_at
    media.review!(creator)

    expect(media.reload.reviewed_by).to eq(reviewer)
    expect(media.reviewed_at).to eq(reviewed_at)
    expect(described_class.reviewed).to include(media)
    expect(described_class.unreviewed).not_to include(media)
  end

  it 'retains attributed change history after saving and reloading' do
    media # Keep creation outside the versioned update being checked.
    with_versioning do
      PaperTrail.request(whodunnit: creator.id.to_s) do
        media.update!(caption: 'Railway station')
      end
    end

    version = media.reload.versions.last
    expect(version.whodunnit).to eq(creator.id.to_s)
    expect(version.changeset['caption']).to eq(['Canal warehouse', 'Railway station'])
    expect(version.reify.caption).to eq('Canal warehouse')
    expect(media.change_history).to include(version)
  end

  it 'round trips the date type and historical date range through the database' do
    media.update!(date_type: :years, date_year: '1880', date_year_end: '1910')
    expect(media.reload).to be_years
    expect(media.date_start).to eq(Date.new(1880, 1, 1))
    expect(media.date_end).to eq(Date.new(1910, 12, 31))
  end
end
