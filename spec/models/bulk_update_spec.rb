# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkUpdate, :versioning do
  it 'rolls back record changes, versions, and audit links when a later record is invalid' do
    first = create(:census1920_record)
    second = create(:census1920_record)
    second.update_column(:occupation, nil)
    update = described_class.create!(user: create(:administrator), year: 1920,
                                     field: 'family_id', value_from: '1', value_to: '2')
    allow(update).to receive(:targets).and_return(Census1920Record.where(id: [first.id, second.id]).order(:id))
    version_count = first.versions.count

    expect { update.perform }.to raise_error(ActiveRecord::RecordInvalid) { |error| expect(error.record).to eq(second) }

    expect(first.reload.family_id.to_s).to eq('1')
    expect(second.reload.family_id.to_s).to eq('1')
    expect(first.versions.count).to eq(version_count)
    expect(update.records.reload).to be_empty
  end
end
