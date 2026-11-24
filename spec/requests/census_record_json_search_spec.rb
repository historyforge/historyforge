# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Census record JSON search', type: :request do
  it 'serializes matching reviewed records when grid pagination is omitted' do
    match = create(:census1940_record, last_name: 'Hasbrouck', reviewed_at: Time.current)
    create(:census1940_record, last_name: 'Hasbrouck')
    create(:census1940_record, last_name: 'Brown', reviewed_at: Time.current)

    get census_records_path(year: 1940, format: :json), params: { s: { last_name_cont: 'Hasbrouck' } }

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to contain_exactly(
      a_hash_including('id' => match.id, 'name' => match.decorate.name, 'year' => 1940)
    )
  end
end
