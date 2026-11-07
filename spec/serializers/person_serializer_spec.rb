# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonSerializer do
  let(:person) { build_stubbed(:person, id: 42, first_name: 'Mary', last_name: 'Jones') }
  let(:url_options) { { host: 'history.example', protocol: 'https', script_name: '/archive' } }
  def serialize(*census_records, census_readable: ->(_record) { true })
    described_class.new(person, census_records:, census_readable:, url_options:)
  end

  it 'keeps Person identity separate from year-specific census observations and their links' do
    earlier = build_stubbed(:census1850_record, id: 1, person_id: person.id, age: 5, pob: 'New York',
                                              street_name: 'Buffalo', reviewed_at: Time.current)
    later = build_stubbed(:census1910_record, id: 1, person_id: person.id, age: 65, pob: 'New York',
                                              occupation: 'Merchant', reviewed_at: Time.current)
    expect(person).not_to receive(:census_records)
    allow(earlier).to receive(:fellows).and_return([])
    allow(later).to receive(:fellows).and_return([])

    result = serialize(later, earlier).serializable_hash

    expect(result).to include(id: 42, name: person.name, canonical_url: "https://history.example/archive/people/#{person.id}")
    expect(result[:summary]).to include('At five, Mary Jones lived on Buffalo', 'In 1910', '“Merchant”')
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
    unreviewed = build_stubbed(:census1910_record, id: 3, person_id: 44)
    unlinked = build_stubbed(:census1910_record, id: 4, reviewed_at: Time.current)
    expect(record).to receive(:fellows).once.and_return([fellow, unreviewed, unlinked])
    expect(fellow).not_to receive(:person)

    serializer = serialize(record, census_readable: ->(row) { row != unreviewed })

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
    allow(record).to receive(:fellows).and_return([head])

    serializer = serialize(record, census_readable: ->(row) { row != head })
    expect(serializer.summary).not_to include(head.name)
    expect(serializer.summary_source_links.pluck(:record_id)).to eq([record.id])

    refreshed = serialize(record)
    expect(refreshed.summary).to include("#{head.name}’s daughter")
    expect(refreshed.summary_source_links.pluck(:record_id)).to eq([record.id, head.id])
  end
end
