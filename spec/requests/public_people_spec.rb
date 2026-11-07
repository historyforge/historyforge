# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public Person pages', type: :request do
  include Devise::Test::IntegrationHelpers

  it 'serves the title, canonical URL, summary and source links to an anonymous crawler' do
    allow(People::PublicUrlOptions).to receive(:call).and_return({})
    person = create(:person)
    record = create(:census1910_record, age: 30, street_name: 'Coddington', street_suffix: 'Rd')
    record.update_columns(person_id: person.id, reviewed_at: Time.current)
    host! 'history.example'
    https!

    get person_path(person, ref: 'search'), headers: { 'User-Agent' => 'Googlebot' }

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('text/html')
    expect(response.headers['X-Robots-Tag']).to be_nil

    html = Nokogiri::HTML(response.body)
    head = html.at_css('head')
    expect(head.at_css('title').text).to eq("#{person.name} | HistoryForge")
    expect(head.css('meta[name="robots"]')).to be_empty
    expect(head.css('link[rel="canonical"]').map { |tag| tag['href'] }).to eq([
      person_url(person, host: 'history.example', protocol: 'https'),
    ])
    summary = html.at_css('section[aria-label="Biography"]')
    expect(html.at_css('body h1').text).to eq(person.name)
    expect(summary.at_css('p').text).to include('lived on Coddington Rd')
    expect(head.css('meta[name="description"]').map { |tag| tag['content'] }).to eq([summary.at_css('p').text])
    expect(summary.at_css('a')['href']).to eq(polymorphic_url(record, host: 'history.example', protocol: 'https'))
  end

  it 'keeps signed-in census evidence out of search metadata' do
    person = create(:person)
    create(:census1910_record, person:, occupation: 'Carpenter')
    sign_in create(:administrator)

    get person_path(person)

    expect(response).to have_http_status(:ok)
    html = Nokogiri::HTML(response.body)
    expect(html.at_css('section[aria-label="Biography"]').text).to include('Carpenter')
    expect(html.at_css('head meta[name="description"]')).to be_nil
  end

  it 'escapes the public description in the metadata attribute' do
    person = create(:person, description: '<p>A <em>local</em> historian "of note".</p>')

    get person_path(person)

    html = Nokogiri::HTML(response.body)
    expect(html.at_css('head meta[name="description"]')['content']).to eq('A local historian "of note".')
  end

  it 'omits the meta description when the public representation has none' do
    get person_path(create(:person))

    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).css('head meta[name="description"]')).to be_empty
  end

  it 'uses a single Person description when a CMS layout also defines one' do
    person = create(:person, description: 'A public history profile.')
    Cms::Page.create!(controller: 'People::MainController', action: 'show',
                     title: 'Profile layout', description: 'Generic profile description')

    get person_path(person)

    expect(response).to have_http_status(:ok)
    head = Nokogiri::HTML(response.body).at_css('head')
    expect(head.css('meta[name="description"]').map { |tag| tag['content'] }).to eq([person.description])
    expect(head.css('link[rel="canonical"]').size).to eq(1)
  end

  it 'serves the existing robots policy without blocking Person paths' do
    get '/robots.txt'

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('text/plain')
    expect(response.body.lines.grep(/\ADisallow:/).map(&:strip)).to contain_exactly('Disallow: /forge', 'Disallow: /*/forge')
  end
end
