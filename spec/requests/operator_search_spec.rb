# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Operator search', :versioning, type: :request do
  let(:operator) { create(:census_taker) }
  let(:other_operator) { create(:census_taker) }
  let(:creation_date) { Time.zone.local(2025, 1, 8, 23, 59) }

  def create_person_as(user, created_at:)
    PaperTrail.request(whodunnit: user.id.to_s) do
      create(:person, created_at:)
    end
  end

  def sign_in_as(user)
    post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } }
  end

  def people_created_by(user, **date_filters)
    get people_path(format: :json), params: { s: { operator_id: user.id, **date_filters }, from: 0, to: 100 }
    expect(response).to have_http_status(:ok)
    response.parsed_body.map { |row| row.dig('name', 'id') }
  end

  it 'lets reviewers search by recorded creator and an inclusive creation date range' do
    reviewer = create(:active_user)
    reviewer.add_role Role.find_by(name: 'reviewer')
    person = create_person_as(operator, created_at: creation_date)
    create_person_as(operator, created_at: creation_date + 1.minute)
    edited_person = create_person_as(other_operator, created_at: creation_date)
    PaperTrail.request(whodunnit: operator.id.to_s) do
      edited_person.update!(notes: 'Edited by the operator')
    end
    sign_in_as(reviewer)

    get people_path, params: { s: { operator_id: operator.id } }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('s[operator_id]', 's[operator_created_from]', 's[operator_created_to]')

    expect(people_created_by(operator, operator_created_from: '2025-01-08', operator_created_to: '2025-01-08'))
      .to eq([person.id])
  end

  it 'limits census takers to their own creations even when they submit another operator ID' do
    person = create_person_as(operator, created_at: creation_date)
    create_person_as(other_operator, created_at: creation_date)
    sign_in_as(operator)

    expect(people_created_by(operator)).to eq([person.id])
    expect(people_created_by(other_operator)).to be_empty
  end

  it 'disallows operator searches by guests' do
    create_person_as(operator, created_at: creation_date)

    expect(people_created_by(operator)).to be_empty
  end

  it 'limits builders to their own creations' do
    builder = create(:builder)
    building = create(:building, created_by: builder)
    create(:building, created_by: operator)
    person = create_person_as(builder, created_at: creation_date)
    create_person_as(operator, created_at: creation_date)
    sign_in_as(builder)

    get buildings_path(format: :json), params: { s: { operator_id: builder.id }, from: 0, to: 100 }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.map { |row| row.dig('street_address', 'id') }).to eq([building.id])

    get buildings_path(format: :json), params: { s: { operator_id: operator.id }, from: 0, to: 100 }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to be_empty

    expect(people_created_by(builder)).to eq([person.id])
    expect(people_created_by(operator)).to be_empty
  end
end
