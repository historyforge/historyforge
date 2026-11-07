# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public Person API v1', type: :request do
  include Devise::Test::IntegrationHelpers

  it 'returns the public representation with source links and shallow household relationships' do
    person = create(:person, notes: 'Private editor notes')
    relative = create(:person, notes: 'Private relative notes')
    locality = create(:locality)
    person.names.create!(first_name: 'Mary', last_name: 'Jones')
    record = create(:census1910_record, locality:, age: 15, pob: 'New York', relation_to_head: 'Daughter',
                                        street_name: 'Coddington', street_suffix: 'Rd', notes: 'Private census notes')
    fellow = create(:census1910_record, locality:, relation_to_head: 'Head')
    unreviewed = create(:census1910_record, locality:, relation_to_head: 'Son')
    record.update_columns(person_id: person.id, reviewed_at: Time.current)
    fellow.update_columns(person_id: relative.id, reviewed_at: Time.current)
    unreviewed.update_columns(person_id: create(:person).id)

    get api_v1_person_path(person)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/json')
    origin = request.base_url
    source = { 'year' => 1910, 'record_id' => record.id, 'url' => "#{origin}#{polymorphic_path(record)}" }
    fellow_source = { 'year' => 1910, 'record_id' => fellow.id, 'url' => "#{origin}#{polymorphic_path(fellow)}" }
    data = response.parsed_body
    expect(data.keys).to contain_exactly(
      'id', 'name', 'alternate_names', 'canonical_url', 'summary', 'summary_source_links', 'description', 'birth_year', 'death_year',
      'census_observations', 'source_links', 'relationships'
    )
    expect(data).to include('id' => person.id, 'name' => person.name, 'canonical_url' => "#{origin}#{person_path(person)}")
    expect(data['alternate_names']).to eq(['Mary Jones'])
    expect(data['summary']).to include('lived on Coddington Rd', "#{fellow.name}’s daughter")
    expect(data['summary_source_links']).to eq([
      source.merge('label' => '1910 census'),
      fellow_source.merge('label' => "1910: #{fellow.name}"),
    ])
    expect(data['census_observations']).to eq([
      record.slice(:id, :name, :year, :occupation, :race, :sex, :age, :relation_to_head, :pob).stringify_keys,
    ])
    expect(data['source_links']).to eq([source])
    expect(data['relationships']).to eq([
      { 'type' => 'census_household_member', 'person_id' => relative.id,
        'person_url' => "#{origin}#{person_path(relative)}", 'source_links' => [source, fellow_source] },
    ])
    expect(response.body).not_to include('Private', polymorphic_path(unreviewed))
  end

  it 'uses the caller’s census-year and record permissions' do
    person = create(:person)
    unreviewed = create(:census1910_record, person:, occupation: 'Carpenter')
    hidden = create(:census1930_record, occupation: 'Banker')
    hidden.update_columns(person_id: person.id, reviewed_at: Time.current)
    allow(Setting).to receive(:can_view_public?).and_call_original
    allow(Setting).to receive(:can_view_public?).with(1930).and_return(false)
    get api_v1_person_path(person, format: :json)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      'summary' => nil, 'summary_source_links' => [], 'census_observations' => [], 'source_links' => [], 'relationships' => []
    )
    expect(response.body).not_to include(polymorphic_path(unreviewed), polymorphic_path(hidden))

    sign_in create(:administrator)
    get api_v1_person_path(person, format: :json)

    expect(response).to have_http_status(:ok)
    expect(response.headers['Cache-Control']).to include('no-store')
    expect(response.parsed_body['source_links'].pluck('url')).to eq([
      "#{request.base_url}#{polymorphic_path(unreviewed)}",
      "#{request.base_url}#{polymorphic_path(hidden)}",
    ])
  end

  it 'returns a JSON 403 when public People access is disabled, including for signed-in callers' do
    person = create(:person)
    allow(Setting).to receive(:can_people_public?).and_return(false)

    get api_v1_person_path(person)
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body).to eq('error' => 'forbidden')

    sign_in create(:administrator)
    get api_v1_person_path(person)
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body).to eq('error' => 'forbidden')
  end

  it 'returns a JSON 404 for a missing person' do
    get api_v1_person_path(0)

    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body).to eq('error' => 'not_found')
  end

  it 'returns a JSON 403 when the Person read ability is denied' do
    person = create(:person)
    ability = Ability.new(nil)
    ability.cannot(:read, Person)
    allow(Ability).to receive(:new).and_return(ability)

    get api_v1_person_path(person)

    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body).to eq('error' => 'forbidden')
  end

  it 'does not route JSON writes' do
    %i[put patch delete].each do |method|
      expect { public_send(method, '/api/v1/people/1.json') }.to raise_error(ActionController::RoutingError)
    end
    expect { post '/api/v1/people.json' }.to raise_error(ActionController::RoutingError)
  end
end
