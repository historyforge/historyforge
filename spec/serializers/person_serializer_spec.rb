# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonSerializer do
  let(:person) { build_stubbed(:person, id: 42, first_name: 'Mary', last_name: 'Jones') }
  let(:routes) do
    routes = ActionDispatch::Routing::RouteSet.new
    routes.draw do
      resources :people, only: :show
      resources :census1850_records, only: :show
      resources :census1910_records, only: :show
    end
    routes.default_url_options[:host] = 'history.example'
    routes.url_helpers
  end
  let(:serializer) { described_class.new(person, routes:) }

  before do
    allow(Setting).to receive(:can_view_public?).and_call_original
    allow(Setting).to receive(:can_view_public?).with(1850).and_return(true)
    allow(Setting).to receive(:can_view_public?).with(1910).and_return(true)
    allow(Setting).to receive(:can_view_public?).with(1930).and_return(false)
  end

  it 'keeps Person identity separate from year-specific census observations and their links' do
    earlier = build_stubbed(:census1850_record, id: 1, person_id: person.id, age: 5, pob: 'New York',
                                              street_name: 'Buffalo', reviewed_at: Time.current)
    later = build_stubbed(:census1910_record, id: 1, person_id: person.id, age: 65, pob: 'New York',
                                              occupation: 'Merchant', reviewed_at: Time.current)
    hidden = build_stubbed(:census1930_record, id: 1, age: 20, reviewed_at: Time.current)
    unreviewed = build_stubbed(:census1910_record, id: 2, age: 30)
    expect(person).to receive(:census_records).once.and_return([later, hidden, unreviewed, earlier])
    allow(earlier).to receive(:fellows).and_return([])
    allow(later).to receive(:fellows).and_return([])

    result = serializer.serializable_hash

    expect(result).to include(id: 42, name: person.name, canonical_url: routes.person_url(person.id))
    expect(result[:summary]).to include('At five, Mary Jones lived on Buffalo', 'In 1910', '“Merchant”')
    expect(result[:census_observations]).to match([
      a_hash_including(id: 1, year: 1850, name: earlier.name, age: 5, pob: 'New York'),
      a_hash_including(id: 1, year: 1910, name: later.name, age: 65, relation_to_head: later.relation_to_head),
    ])
    expect(result[:census_observations].first).not_to have_key(:relation_to_head)
    expect(result[:source_links]).to eq([
      { year: 1850, record_id: 1, url: routes.polymorphic_url(earlier) },
      { year: 1910, record_id: 1, url: routes.polymorphic_url(later) },
    ])
    expect(result[:summary_source_links]).to eq([
      { year: 1850, record_id: 1, url: routes.polymorphic_url(earlier), label: '1850 census' },
      { year: 1910, record_id: 1, url: routes.polymorphic_url(later), label: '1910 census' },
    ])
  end

  it 'links other people only through public evidence of a shared census household' do
    record = build_stubbed(:census1910_record, id: 1, reviewed_at: Time.current)
    fellow = build_stubbed(:census1910_record, id: 2, person_id: 43, relation_to_head: 'Daughter', reviewed_at: Time.current)
    unreviewed = build_stubbed(:census1910_record, id: 3, person_id: 44)
    unlinked = build_stubbed(:census1910_record, id: 4, reviewed_at: Time.current)
    allow(person).to receive(:census_records).and_return([record])
    expect(record).to receive(:fellows).once.and_return([fellow, unreviewed, unlinked])
    expect(fellow).not_to receive(:person)

    expect(serializer.relationships).to eq([
      {
        type: 'census_household_member',
        person_id: 43,
        person_url: routes.person_url(43),
        source_links: [
          { year: 1910, record_id: 1, url: routes.polymorphic_url(record) },
          { year: 1910, record_id: 2, url: routes.polymorphic_url(fellow) },
        ],
      },
    ])
    expect(serializer.relationships.size).to eq(1)
  end

  it 'builds the summary without loading household members when the row is a household head' do
    record = build_stubbed(:census1910_record, id: 1, occupation: 'Merchant', reviewed_at: Time.current)
    allow(person).to receive(:census_records).and_return([record])
    expect(record).not_to receive(:fellows)

    expect(serializer.summary).to include('“Merchant”')
  end

  it 'only names and cites a household head whose census row is public' do
    record = build_stubbed(:census1910_record, id: 1, person_id: person.id, relation_to_head: 'Daughter',
                                              street_name: 'Buffalo', reviewed_at: Time.current)
    head = build_stubbed(:census1910_record, id: 2, relation_to_head: 'Head')
    allow(person).to receive(:census_records).and_return([record])
    allow(record).to receive(:fellows).and_return([head])

    expect(serializer.summary).not_to include(head.name)
    expect(serializer.summary_source_links.pluck(:record_id)).to eq([record.id])

    head.reviewed_at = Time.current
    refreshed = described_class.new(person, routes:)
    expect(refreshed.summary).to include("#{head.name}’s daughter")
    expect(refreshed.summary_source_links.pluck(:record_id)).to eq([record.id, head.id])
  end
end
