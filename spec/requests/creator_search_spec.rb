# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creator search', :versioning, type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:creator) { create(:census_taker) }
  let(:other_creator) { create(:census_taker) }
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
    get people_path(format: :json), params: { s: { creator_id: user.id, **date_filters }, from: 0, to: 100 }
    expect(response).to have_http_status(:ok)
    response.parsed_body.map { |row| row.dig('name', 'id') }
  end

  it 'lets reviewers search by recorded creator and an inclusive creation date range' do
    reviewer = create(:active_user)
    reviewer.add_role Role.find_by(name: 'reviewer')
    person = create_person_as(creator, created_at: creation_date)
    create_person_as(creator, created_at: creation_date + 1.minute)
    edited_person = create_person_as(other_creator, created_at: creation_date)
    PaperTrail.request(whodunnit: creator.id.to_s) do
      edited_person.update!(notes: 'Edited by the creator')
    end
    sign_in_as(reviewer)

    get people_path, params: { s: { creator_id: creator.id, creation_date_range: 'last7' } }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('s[creator_id]', 's[creation_date_from]', 's[creation_date_to]')
    form = Nokogiri::HTML(response.body)
    expect(form.at_css('#creator_lookup')['value']).to eq(creator.login)
    expect(form.at_css('form[data-controller="creator-picker"] #s_creator_id')['value']).to eq(creator.id.to_s)
    chips = form.css('#attribute-filters [data-creator-filter-chip]')
    expect(chips.map(&:text)).to eq(["Created by #{creator.login}", 'Created in the last 7 days'])
    expect(chips.css('button').map { |button| button['aria-label'] })
      .to eq(['Remove Created by filter', 'Remove Creation date filter'])

    expect(people_created_by(creator, creation_date_from: '2025-01-08', creation_date_to: '2025-01-08'))
      .to eq([person.id])
  end

  it 'limits census takers to their own creations even when they submit another creator ID' do
    person = PaperTrail.request(enabled: false, whodunnit: creator.id.to_s) do
      create(:person, created_at: creation_date)
    end
    expect(person.versions).to be_empty
    create_person_as(other_creator, created_at: creation_date)
    sign_in_as(creator)

    expect(people_created_by(creator)).to eq([person.id])
    expect(people_created_by(other_creator)).to be_empty
  end

  it 'applies rolling presets by calendar date and supports a custom end date' do
    travel_to(Time.zone.local(2025, 1, 14, 12)) do
      recent = create_person_as(creator, created_at: creation_date)
      older = create_person_as(creator, created_at: creation_date - 1.day)
      sign_in_as(creator)

      expect(people_created_by(creator, creation_date_range: 'last7')).to eq([recent.id])
      expect(people_created_by(creator, creation_date_range: 'today')).to be_empty
      expect(people_created_by(creator, creation_date_range: 'custom', creation_date_to: '2025-01-07')).to eq([older.id])

      filters = { s: { creation_date_range: 'last7' } }
      get people_path, params: filters
      expect(response).to have_http_status(:ok)
      chips = Nokogiri::HTML(response.body).css('#attribute-filters [data-creator-filter-chip]')
      expect(chips.map(&:text)).to eq(['Created in the last 7 days'])

      get people_path(format: :json), params: filters.merge(from: 0, to: 100)
      expect(response.parsed_body.map { |row| row.dig('name', 'id') }).to eq([recent.id])
    end
  end

  it 'ignores creator filters from guests and users without creator search permission' do
    person = create_person_as(creator, created_at: creation_date)
    other_person = create_person_as(other_creator, created_at: creation_date)

    expect(people_created_by(creator, creation_date_range: 'today')).to contain_exactly(person.id, other_person.id)

    sign_in_as(create(:active_user))
    expect(people_created_by(creator, creation_date_range: 'today')).to contain_exactly(person.id, other_person.id)
  end

  it 'finds creators by name or email without returning email addresses' do
    reviewer = create(:active_user)
    reviewer.add_role Role.find_by(name: 'reviewer')
    match = create(:active_user, login: 'Volunteer A', full_name: 'Marisol Ruiz', email: 'marisol@example.test')
    sign_in_as(reviewer)

    ['Ruiz', 'Volunteer A', 'marisol@example.test'].each do |term|
      get creator_autocomplete_users_path(format: :json), params: { term: }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([{ 'id' => match.id, 'name' => 'Marisol Ruiz', 'login' => 'Volunteer A' }])
    end
  end

  it 'restricts creator autocomplete to users who can search for other creators' do
    get creator_autocomplete_users_path(format: :json), params: { term: creator.login }
    expect(response).to have_http_status(:forbidden)

    sign_in_as(creator)
    get creator_autocomplete_users_path(format: :json), params: { term: other_creator.login }
    expect(response).to have_http_status(:forbidden)
  end

  it 'shows recent creations and links to searches for the signed-in creator' do
    allow(Setting).to receive(:can_people_private?).and_return(true)
    allow(Setting).to receive(:can_view_private?).and_call_original
    allow(Setting).to receive(:can_view_private?).with(1910).and_return(true)
    person = create_person_as(creator, created_at: creation_date)
    other_person = create_person_as(other_creator, created_at: creation_date)
    building = create(:building, created_by: creator, created_at: creation_date + 1.day)
    census_record = create(:census1910_record, created_by: creator, created_at: creation_date + 2.days)
    sign_in_as(creator)

    get my_stuff_users_path, params: { s: { creator_id: other_creator.id } }
    expect(response).to have_http_status(:ok)
    html = Nokogiri::HTML(response.body)
    menu = html.at_css('#my-menu-item')
    expect(menu.at_css('.dropdown-toggle').text).to eq('My')
    menu_links = menu.css('.dropdown-item').map { |link| link['href'] }
    filters = { creator_id: creator.id }
    search_links = [buildings_path(s: filters), people_path(s: filters), census_records_path(year: 1910, s: filters)]
    expect(menu_links).to include(my_stuff_users_path, *search_links)
    recent_links = html.css('#recent-creations a').map { |link| link['href'] }
    expect(recent_links).to eq([census_record_path(year: 1910, id: census_record.id), building_path(building), person_path(person)])
    expect(recent_links).not_to include(person_path(other_person))
  end

  it 'loads older creations in place without repeating records with the same timestamp' do
    allow(Setting).to receive(:can_people_private?).and_return(true)
    people = Array.new(16) { create_person_as(creator, created_at: creation_date) }
    sign_in_as(creator)

    get my_stuff_users_path
    page = Nokogiri::HTML(response.body)
    expect(page.css('#recent-creations a').map { |link| link['href'] }).to eq(people.drop(1).reverse.map { |person| person_path(person) })
    load_more = page.at_css('#load-more-creations a')

    get load_more['href'], headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
    expect(response).to have_http_status(:ok)
    streams = Nokogiri::HTML.fragment(response.body)
    expect(streams.css('turbo-stream[action="append"][target="recent-creations"] a').map { |link| link['href'] })
      .to eq([person_path(people.first)])
    expect(streams.at_css('turbo-stream[action="replace"][target="load-more-creations"] a')).to be_nil
  end

  it 'lets person record editors search for people they created' do
    editor = create(:active_user)
    editor.add_role Role.find_by(name: 'person record editor')
    person = create_person_as(editor, created_at: creation_date)
    create_person_as(other_creator, created_at: creation_date)
    sign_in_as(editor)

    expect(people_created_by(editor)).to eq([person.id])
    expect(people_created_by(other_creator)).to be_empty
  end

  it 'limits builders to their own creations' do
    builder = create(:builder)
    building = create(:building, created_by: builder)
    create(:building, created_by: creator)
    person = create_person_as(builder, created_at: creation_date)
    create_person_as(creator, created_at: creation_date)
    sign_in_as(builder)

    get buildings_path(format: :json), params: { s: { creator_id: builder.id }, from: 0, to: 100 }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.map { |row| row.dig('street_address', 'id') }).to eq([building.id])

    get buildings_path(format: :json), params: { s: { creator_id: creator.id }, from: 0, to: 100 }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to be_empty

    expect(people_created_by(builder)).to eq([person.id])
    expect(people_created_by(creator)).to be_empty
  end
end
