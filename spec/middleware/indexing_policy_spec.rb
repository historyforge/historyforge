# frozen_string_literal: true

require 'spec_helper'
require 'rack/mock'
require 'rack/static'
require_relative '../../lib/middleware/indexing_policy'

RSpec.describe IndexingPolicy do
  let(:body) { ['page'] }
  let(:app) { ->(_env) { [200, { 'content-type' => 'text/html' }.freeze, body] } }

  it 'does not alter responses when disabled' do
    response = [200, { 'content-type' => 'text/html' }, body]
    upstream = ->(_env) { response }
    expect(described_class.new(upstream, disallow_indexing: false).call({})).to equal(response)
  end

  it 'requires an explicit true environment value' do
    [nil, '', 'false', '0'].each do |value|
      allow(ENV).to receive(:[]).with('DISALLOW_INDEXING').and_return(value)
      expect(described_class.new(app).call({})[1]).not_to have_key('x-robots-tag')
    end
    allow(ENV).to receive(:[]).with('DISALLOW_INDEXING').and_return('true')
    expect(described_class.new(app).call({})[1]['x-robots-tag']).to eq('noindex, nofollow')
  end

  it 'preserves status, other headers and streaming body for pages, redirects and errors' do
    [200, 302, 404, 500].each do |status|
      headers = { 'location' => '/next' }.freeze
      response = described_class.new(->(_env) { [status, headers, body] }, disallow_indexing: true).call({})
      expect(response).to eq([status, { 'location' => '/next', 'x-robots-tag' => 'noindex, nofollow' }, body])
      expect(response.last).to equal(body)
    end
  end

  it 'preserves the real sites robots file and covers static responses when enabled' do
    static = Rack::Static.new(app, urls: ['/robots.txt'], root: File.expand_path('../../public', __dir__))
    normal = Rack::MockRequest.new(described_class.new(static, disallow_indexing: false)).get('/robots.txt')
    expect(normal.body).to include('Disallow: /forge')
    expect(normal['x-robots-tag']).to be_nil
    demo_robots = Rack::MockRequest.new(described_class.new(static, disallow_indexing: true)).get('/robots.txt')
    expect(demo_robots.body).to eq(normal.body)
    expect(demo_robots['x-robots-tag']).to eq('noindex, nofollow')

    # Headers cover static files as well as application responses.
    static = Rack::Static.new(app, urls: { '/sample.txt' => 'robots.txt' }, root: File.expand_path('../../public', __dir__))
    demo = Rack::MockRequest.new(described_class.new(static, disallow_indexing: true)).get('/sample.txt')
    expect(demo.body).to include('Disallow: /forge')
    expect(demo['x-robots-tag']).to eq('noindex, nofollow')
  end
end
