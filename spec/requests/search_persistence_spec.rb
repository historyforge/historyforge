# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search persistence over HTTP', type: :request do
  let!(:older) { create(:person, birth_year: 1850) }
  let!(:newer) { create(:person, birth_year: 1900) }
  let!(:excluded) { create(:person, birth_year: 1950) }
  let(:filters) do
    { s: { birth_year_in: %w[1850 1900] }, f: %w[name birth_year],
      sort: { '0' => { colId: 'birth_year', sort: 'desc' } } }
  end

  [false, true].each do |authenticated|
    context(authenticated ? 'signed in' : 'as a guest') do
      before do
        if authenticated
          user = create(:active_user)
          post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } }
        end
      end

      it 'restores nested filters, selected columns, and ordering without a redirect loop' do
        get people_path, params: filters
        expect(response).to have_http_status(:ok)
        get root_path
        get people_path
        expect(response).to have_http_status(:redirect)
        restored = Rack::Utils.parse_nested_query(URI.parse(response.location).query)
        expect(restored).to include(JSON.parse(filters.to_json))
        follow_redirect!
        expect(response).to have_http_status(:ok)

        get people_path(format: :json), params: restored.merge('from' => '0', 'to' => '1')
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.map { |row| row.dig('name', 'id') }).to eq([newer.id])
        expect(response.parsed_body.first.fetch('birth_year')).to eq(1900)
        get people_path(format: :json), params: restored.merge('from' => '1', 'to' => '2')
        expect(response.parsed_body.map { |row| row.dig('name', 'id') }).to eq([older.id])
      end

      it "does not restore one visitor's search for another visitor" do
        get people_path, params: filters
        other = open_session
        if authenticated
          other_user = create(:active_user)
          other.post user_session_path, params: { user: { email: other_user.email, password: 'b1g_sekrit' } }
        end
        other.get people_path
        expect(other.response).to have_http_status(:ok)
        other.get people_path(format: :json), params: { f: %w[name birth_year] }
        expect(other.response.parsed_body.map { |row| row.dig('name', 'id') })
          .to contain_exactly(older.id, newer.id, excluded.id)
      end

      it 'clears saved filters on reset' do
        get people_path, params: filters
        get people_path, params: { reset: '1' }
        expect(response).to redirect_to(people_path)
        follow_redirect!
        expect(response).to have_http_status(:ok)
        get people_path
        expect(response).to have_http_status(:ok)
        get people_path(format: :json), params: { f: %w[name birth_year] }
        expect(response.parsed_body.map { |row| row.dig('name', 'id') })
          .to contain_exactly(older.id, newer.id, excluded.id)
      end
    end
  end
end
