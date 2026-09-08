# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe 'Locality-scoped search responses', type: :request do
  let!(:first_locality) { create(:locality) }
  let!(:second_locality) { create(:locality) }

  %i[people buildings census].each do |directory|
    context "for #{directory}" do
      let(:path) do
        { people: '/people', buildings: '/buildings', census: '/census/1910' }.fetch(directory)
      end
      let(:cell) { directory == :buildings ? 'street_address' : 'name' }
      let(:fields) { [directory == :buildings ? 'street_address' : 'name'] }
      let!(:first_record) { directory_record(directory, first_locality) }
      let!(:second_record) { directory_record(directory, second_locality) }

      it 'limits JSON results to the selected locality and remembers a switch' do
        get "#{path}.json", params: { locality_slug: first_locality.slug, f: fields, from: 0, to: 100 }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.map { |row| row.fetch(cell).fetch('id') }).to eq([first_record.id])
        expect(Current.locality_id).to be_nil

        get "#{path}.json", params: { locality_slug: second_locality.slug, f: fields, from: 0, to: 100 }
        expect(response.parsed_body.map { |row| row.fetch(cell).fetch('id') }).to eq([second_record.id])
        get "#{path}.json", params: { f: fields, from: 0, to: 100 }
        expect(response.parsed_body.map { |row| row.fetch(cell).fetch('id') }).to eq([second_record.id])
      end

      it 'streams only the selected locality into CSV after the controller finishes' do
        get "#{path}.csv", params: { locality_slug: first_locality.slug, f: fields }
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to include('attachment;', '.csv')
        expect(Current.locality_id).to be_nil
        rows = CSV.parse(response.body)
        expect(rows.drop(1).map { |row| row.last.to_i }).to eq([first_record.id])
      end

      it 'does not leak the selection into another browser session' do
        get "#{path}.json", params: { locality_slug: first_locality.slug, f: fields, from: 0, to: 100 }
        other = open_session
        other.get "#{path}.json", params: { f: fields, from: 0, to: 100 }
        expect(other.response).to have_http_status(:ok)
        expect(other.response.parsed_body.map { |row| row.fetch(cell).fetch('id') })
          .to contain_exactly(first_record.id, second_record.id)
      end
    end
  end

  def directory_record(directory, locality)
    case directory
    when :people
      create(:person, localities: [locality])
    when :buildings
      create(:building, :reviewed, locality:)
    when :census
      create(:census1910_record, locality:, reviewed_at: 1.day.ago)
    end
  end
end
