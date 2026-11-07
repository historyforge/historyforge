# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public Person sitemaps', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('BASE_URL').and_return('history.example')
    allow(ENV).to receive(:[]).with('DISALLOW_INDEXING').and_return(nil)
    host! 'history.example'
    https!
  end

  def xml_values(path)
    Nokogiri::XML(response.body) { |config| config.strict }.xpath(path, 's' => People::Sitemap::NAMESPACE).map(&:text)
  end

  it 'indexes occupied ID ranges and lists each canonical Person URL once' do
    stub_const('People::Sitemap::SHARD_SIZE', 2)
    first = create(:person, id: 2)
    second = create(:person, id: 3)
    last = create(:person, id: 9)

    get sitemap_path

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/xml')
    expect(xml_values('/s:sitemapindex/s:sitemap/s:loc')).to eq(
      [0, 1, 4].map { |shard| "https://history.example#{people_sitemap_path(shard:)}" }
    )

    { 0 => first, 1 => second, 4 => last }.each do |shard, person|
      get people_sitemap_path(shard:)
      expect(response).to have_http_status(:ok)
      expect(xml_values('/s:urlset/s:url/s:loc')).to eq(["https://history.example#{person_path(person)}"])
    end

    get people_sitemap_path(shard: 2)
    expect(response).to have_http_status(:not_found)
  end

  it 'uses the newest timestamp from the Person and its public reviewed census records' do
    person = create(:person, updated_at: Time.utc(2020))
    record = create(:census1910_record)
    record.update_columns(person_id: person.id, updated_at: Time.utc(2021), reviewed_at: Time.utc(2022))
    unreviewed = create(:census1910_record)
    unreviewed.update_columns(person_id: person.id, updated_at: Time.utc(2024))
    hidden = create(:census1930_record)
    hidden.update_columns(person_id: person.id, updated_at: Time.utc(2025), reviewed_at: Time.utc(2025))
    allow(Setting).to receive(:can_view_public?).and_call_original
    allow(Setting).to receive(:can_view_public?).with(1930).and_return(false)

    get people_sitemap_path(shard: (person.id - 1) / People::Sitemap::SHARD_SIZE)

    expect(response).to have_http_status(:ok)
    expect(xml_values('/s:urlset/s:url/s:lastmod')).to eq(['2022-01-01T00:00:00Z'])
  end

  it 'uses the same canonical URL in the sitemap, HTML, JSON-LD, and API' do
    person = create(:person)
    host! 'alias.example'

    get person_path(person)

    canonical_url = "https://history.example#{person_path(person)}"
    html = Nokogiri::HTML(response.body)
    expect(html.at_css('link[rel="canonical"]')['href']).to eq(canonical_url)
    expect(JSON.parse(html.at_css('script[type="application/ld+json"]').text)['url']).to eq(canonical_url)

    get api_v1_person_path(person)
    expect(response.parsed_body['canonical_url']).to eq(canonical_url)

    get people_sitemap_path(shard: (person.id - 1) / People::Sitemap::SHARD_SIZE)
    expect(xml_values('/s:urlset/s:url/s:loc')).to eq([canonical_url])
  end

  it 'refreshes cached shards after the TTL and gates cached sitemaps on public access' do
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
    person = create(:person)
    shard = people_sitemap_path(shard: (person.id - 1) / People::Sitemap::SHARD_SIZE)
    get sitemap_path
    get shard
    original = response.body

    person.update!(updated_at: person.updated_at + 1.day)
    get shard
    expect(response.body).to eq(original)
    travel People::Sitemap::CACHE_TTL + 1.second do
      get shard
      expect(xml_values('/s:urlset/s:url/s:lastmod')).to eq([person.updated_at.utc.iso8601])
    end

    allow(Setting).to receive(:can_people_public?).and_return(false)
    [sitemap_path, shard].each do |path|
      get path
      expect(response).to have_http_status(:not_found)
    end

    allow(Setting).to receive(:can_people_public?).and_return(true)
    allow(ENV).to receive(:[]).with('DISALLOW_INDEXING').and_return('true')
    get sitemap_path
    expect(response).to have_http_status(:not_found)
  end

  it 'keeps cached output separate by request origin when BASE_URL is unset' do
    allow(ENV).to receive(:[]).with('BASE_URL').and_return(nil)
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
    person = create(:person)
    shard = people_sitemap_path(shard: (person.id - 1) / People::Sitemap::SHARD_SIZE)

    %w[first.example second.example].each do |host|
      host! host
      get shard
      expect(xml_values('/s:urlset/s:url/s:loc')).to eq(["https://#{host}#{person_path(person)}"])
    end
  end
end
