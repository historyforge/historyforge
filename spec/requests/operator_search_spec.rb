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
    form = Nokogiri::HTML(response.body)
    expect(form.at_css('#operator_lookup')['value']).to eq(operator.login)
    expect(form.at_css('[data-target="operator-picker.toggle"]').text).to eq('My stuff')
    expect(form.at_css('form[data-controller="operator-picker"]')['data-operator-picker-mine']).to eq(reviewer.id.to_s)

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

  it 'finds operators by name or email without returning email addresses' do
    reviewer = create(:active_user)
    reviewer.add_role Role.find_by(name: 'reviewer')
    match = create(:active_user, login: 'Volunteer A', full_name: 'Marisol Ruiz', email: 'marisol@example.test')
    sign_in_as(reviewer)

    ['Ruiz', 'Volunteer A', 'marisol@example.test'].each do |term|
      get operator_autocomplete_users_path(format: :json), params: { term: }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([{ 'id' => match.id, 'name' => 'Marisol Ruiz', 'login' => 'Volunteer A' }])
    end
  end

  it 'restricts operator autocomplete to users who can search for other operators' do
    get operator_autocomplete_users_path(format: :json), params: { term: operator.login }
    expect(response).to have_http_status(:forbidden)

    sign_in_as(operator)
    get operator_autocomplete_users_path(format: :json), params: { term: other_operator.login }
    expect(response).to have_http_status(:forbidden)
  end

  it 'links from the account menu to searches for the signed-in operator' do
    allow(Setting).to receive(:can_people_private?).and_return(true)
    allow(Setting).to receive(:can_view_private?).and_call_original
    allow(Setting).to receive(:can_view_private?).with(1910).and_return(true)
    sign_in_as(operator)

    get my_stuff_users_path, params: { s: { operator_id: other_operator.id } }
    expect(response).to have_http_status(:ok)
    html = Nokogiri::HTML(response.body)
    menu_link = html.css('#user-menu-item a').find { |link| link.text == 'My stuff' }
    expect(menu_link['href']).to eq(my_stuff_users_path)
    links = html.css('.list-group a').map { |link| link['href'] }
    filters = { operator_id: operator.id }
    expect(links).to include(buildings_path(s: filters), people_path(s: filters), census_records_path(year: 1910, s: filters))
  end

  it 'lets person record editors search for people they created' do
    editor = create(:active_user)
    editor.add_role Role.find_by(name: 'person record editor')
    person = create_person_as(editor, created_at: creation_date)
    create_person_as(other_operator, created_at: creation_date)
    sign_in_as(editor)

    expect(people_created_by(editor)).to eq([person.id])
    expect(people_created_by(other_operator)).to be_empty
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
