# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Building response formats', type: :request do
  let(:building) { create(:building, :reviewed) }

  it 'serves JSON when requested' do
    get building_path(building), headers: { 'Accept' => 'application/json' }

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/json')
  end

  it 'returns 406 for unsupported Accept headers' do
    get building_path(building), headers: { 'Accept' => 'application/xml' }

    expect(response).to have_http_status(:not_acceptable)
    expect(response.body).to be_empty
  end
end
