# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Narrative search', type: :request do
  let(:author) { create(:active_user) }
  let(:person) { create(:person, last_name: 'Treman') }
  let!(:match) do
    create(:narrative, created_by: author, reviewed_at: Time.current,
                       people: [person], story: 'A story about the mill.', sources: 'Local newspaper')
  end
  let!(:other) do
    create(:narrative, created_by: author, reviewed_at: Time.current,
                       story: 'A story about the Treman railroad.', sources: 'Local newspaper')
  end
  let!(:unreviewed) do
    create(:narrative, created_by: author, people: [person],
                       story: 'An unpublished draft.', sources: 'Local newspaper')
  end

  it 'matches part of a linked name and restores the search on a later visit' do
    get narratives_path, params: { q: 'REMAN' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(match.story.to_plain_text)
    expect(response.body).not_to include(other.story.to_plain_text, unreviewed.story.to_plain_text)

    get narratives_path
    expect(response).to redirect_to(narratives_path(q: { name_cont: 'REMAN' }, page: 1))
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(match.story.to_plain_text)
  end

  it 'matches alternate person names and linked building names' do
    person.names.create!(first_name: 'Anna', last_name: 'Appleton')
    other.buildings << create(:building, name: 'Appleton Block')

    get narratives_path, params: { q: 'ppleto' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(match.story.to_plain_text, other.story.to_plain_text)
  end

  it 'accepts the existing structured search form' do
    get narratives_path, params: { q: { full_text_search: 'railroad' } }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(other.story.to_plain_text)
    expect(response.body).not_to include(match.story.to_plain_text)
  end

  it 'rejects arrays as the search query' do
    get narratives_path, params: { q: ['Treman'] }

    expect(response).to have_http_status(:bad_request)
  end
end
