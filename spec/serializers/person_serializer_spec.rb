# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonSerializer do
  let(:person) { build_stubbed(:person, id: 42, first_name: 'Mary', last_name: 'Jones', sex: 'F') }
  let(:url_options) { { host: 'history.example', protocol: 'https', script_name: '/archive' } }

  before { allow(People::PublicUrlOptions).to receive(:call).and_return({}) }

  def serialize(*census_records, households: {})
    census_households = census_records.index_with { People::CensusHousehold::Result.new(fellows: [], head: nil) }.merge(households)
    described_class.new(person, census_records:, census_households:, url_options:)
  end

  it 'keeps Person identity separate from year-specific census observations and their links' do
    earlier = build_stubbed(:census1850_record, id: 1, person_id: person.id, age: 5, pob: 'New York',
                                              street_name: 'Buffalo', reviewed_at: Time.current)
    later = build_stubbed(:census1910_record, id: 1, person_id: person.id, age: 65, pob: 'New York',
                                              occupation: 'Merchant', reviewed_at: Time.current)
    expect(person).not_to receive(:census_records)
    expect(earlier).not_to receive(:fellows)
    expect(later).not_to receive(:fellows)

    result = serialize(later, earlier).serializable_hash

    expect(result).to include(id: 42, name: person.name, canonical_url: "https://history.example/archive/people/#{person.id}")
    expect(result[:summary]).to start_with('Mary Jones worked as “Merchant” in 1910.')
    expect(result[:summary]).to include('She lived on Buffalo', 'in 1850.')
    expect(result[:census_observations]).to match([
      a_hash_including(id: 1, year: 1850, name: earlier.name, age: 5, pob: 'New York'),
      a_hash_including(id: 1, year: 1910, name: later.name, age: 65, relation_to_head: later.relation_to_head),
    ])
    expect(result[:census_observations].first).not_to have_key(:relation_to_head)
    expect(result[:source_links]).to eq([
      { year: 1850, record_id: 1, url: "https://history.example/archive/census/1850/#{earlier.id}" },
      { year: 1910, record_id: 1, url: "https://history.example/archive/census/1910/#{later.id}" },
    ])
    expect(result[:summary_source_links]).to eq([
      { year: 1850, record_id: 1, url: "https://history.example/archive/census/1850/#{earlier.id}", label: '1850 census' },
      { year: 1910, record_id: 1, url: "https://history.example/archive/census/1910/#{later.id}", label: '1910 census' },
    ])
  end

  it 'links other people only through public evidence of a shared census household' do
    record = build_stubbed(:census1910_record, id: 1, reviewed_at: Time.current)
    fellow = build_stubbed(:census1910_record, id: 2, person_id: 43, relation_to_head: 'Daughter', reviewed_at: Time.current)
    unlinked = build_stubbed(:census1910_record, id: 4, reviewed_at: Time.current)
    expect(record).not_to receive(:fellows)
    expect(fellow).not_to receive(:person)

    household = People::CensusHousehold::Result.new(fellows: [fellow, unlinked], head: nil)
    serializer = serialize(record, households: { record => household })

    expect(serializer.relationships).to eq([
      {
        type: 'census_household_member',
        person_id: 43,
        person_url: 'https://history.example/archive/people/43',
        source_links: [
          { year: 1910, record_id: 1, url: "https://history.example/archive/census/1910/#{record.id}" },
          { year: 1910, record_id: 2, url: "https://history.example/archive/census/1910/#{fellow.id}" },
        ],
      },
    ])
    expect(serializer.relationships.size).to eq(1)
  end

  it 'builds the summary without loading household members when the row is a household head' do
    record = build_stubbed(:census1910_record, id: 1, occupation: 'Merchant', reviewed_at: Time.current)
    expect(record).not_to receive(:fellows)

    expect(serialize(record).summary).to include('“Merchant”')
  end

  it 'only names and cites a household head approved by the caller' do
    record = build_stubbed(:census1910_record, id: 1, person_id: person.id, relation_to_head: 'Daughter',
                                              street_name: 'Buffalo', reviewed_at: Time.current)
    head = build_stubbed(:census1910_record, id: 2, relation_to_head: 'Head', reviewed_at: Time.current)
    expect(record).not_to receive(:fellows)

    serializer = serialize(record)
    expect(serializer.summary).not_to include(head.name)
    expect(serializer.summary_source_links.pluck(:record_id)).to eq([record.id])

    household = People::CensusHousehold::Result.new(fellows: [head], head:)
    refreshed = serialize(record, households: { record => household })
    expect(refreshed.summary).to include("the daughter of #{head.name}")
    expect(refreshed.summary_source_links.pluck(:record_id)).to eq([record.id, head.id])
  end
end
