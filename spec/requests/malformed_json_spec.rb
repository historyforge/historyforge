# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Malformed JSON', type: :request do
  it 'rejects a malformed JSON probe without echoing the body' do
    payload = '{"code":"unexpected "quote""}'
    post '/run', params: payload, headers: { 'CONTENT_TYPE' => 'application/json' }

    expect(response).to have_http_status(:bad_request)
    expect(response.body).to be_empty
  end
end
