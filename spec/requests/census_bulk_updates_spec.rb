# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Census bulk updates', type: :request do
  let(:user) { create(:administrator) }
  let(:bulk_update) { BulkUpdate.create!(user: user, year: 1920, field: 'family_id') }
  let(:changes) { { field: 'family_id', value_from: '1', value_to: '2' } }

  before do
    post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } }
  end

  it 'previews matches without changing records, then updates only matches when confirmed' do
    matching = create(:census1920_record)
    other = create(:census1920_record, family_id: '9')
    path = census_bulk_path(year: 1920, id: bulk_update.id)

    patch path, params: { bulk_update: changes }
    expect(response).to have_http_status(422)
    expect(response.body).to include('Confirm that you want to update 1 record.')
    expect(matching.reload.family_id.to_s).to eq('1')
    expect(bulk_update.records).to be_empty

    patch path, params: { bulk_update: changes.merge(confirm: '1') }
    expect(response).to redirect_to(path)
    expect(matching.reload.family_id.to_s).to eq('2')
    expect(other.reload.family_id.to_s).to eq('9')
    expect(bulk_update.records.reload.map(&:record)).to eq([matching])
  end

  it 'rejects viewing, editing, applying, and deleting a bulk update through another census year' do
    record = create(:census1920_record)
    path = census_bulk_path(year: 1910, id: bulk_update.id)

    expect { get path }.to raise_error(ActiveRecord::RecordNotFound)
    expect { get edit_census_bulk_path(year: 1910, id: bulk_update.id) }
      .to raise_error(ActiveRecord::RecordNotFound)
    expect { patch path, params: { bulk_update: changes.merge(confirm: '1') } }
      .to raise_error(ActiveRecord::RecordNotFound)
    expect { delete path }.to raise_error(ActiveRecord::RecordNotFound)

    expect(record.reload.family_id.to_s).to eq('1')
    expect(bulk_update.reload.value_to).to be_nil
    expect(bulk_update.records).to be_empty
  end
end
