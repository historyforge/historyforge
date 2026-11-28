# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Census record response formats', type: :request do
  let(:record) do
    create(:census1880_record, locality: create(:locality), first_name: 'Beatrice', last_name: 'Brown',
                              family_id: '1', page_number: 1, page_side: 'A', line_number: 1,
                              relation_to_head: 'Head', sex: 'F', race: 'W', enum_dist: '1',
                              reviewed_at: Time.current)
  end

  it 'serves the HTML detail page' do
    get census_record_path(year: 1880, id: record.id)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('text/html')
  end

  it 'serves the public census representation at the JSON detail URL' do
    get census_record_path(year: 1880, id: record.id, format: :json)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq(
      'id' => record.id, 'name' => record.decorate.name, 'year' => 1880,
      'occupation' => record.decorate.occupation, 'race' => 'White', 'sex' => 'Female',
      'age' => record.age, 'relation_to_head' => 'Head'
    )
  end

  it 'negotiates JSON using the Accept header' do
    get census_record_path(year: 1880, id: record.id), headers: { 'Accept' => 'application/json' }

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/json')
    expect(response.parsed_body).to include('id' => record.id)
  end

  it 'returns 406 for unsupported formats' do
    get census_record_path(year: 1880, id: record.id), headers: { 'Accept' => 'application/xml' }

    expect(response).to have_http_status(:not_acceptable)
    expect(response.body).to be_empty
  end

  it 'does not expose unreviewed records to anonymous callers' do
    record.update!(reviewed_at: nil)

    get census_record_path(year: 1880, id: record.id, format: :json)

    expect(response).to redirect_to(root_path)
  end

  it 'serves records from years without a relationship column' do
    older_record = create(:census1850_record, locality: record.locality, reviewed_at: Time.current,
                                            first_name: 'Abigail', last_name: 'Brown', family_id: '1',
                                            page_number: 1, line_number: 1)

    get census_record_path(year: 1850, id: older_record.id, format: :json)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include('id' => older_record.id, 'year' => 1850)
    expect(response.parsed_body).not_to have_key('relation_to_head')
  end
end
