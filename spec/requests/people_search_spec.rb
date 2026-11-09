# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'People search', type: :request do
  it 'matches first and last names regardless of capitalization, including alternate names' do
    person = create(:person, first_name: 'Amy', last_name: 'Atwater')
    create(:person_name, person:, first_name: 'Amelia', last_name: 'Smith')
    create(:person, first_name: 'Alice', last_name: 'Robinson')

    [
      { names_last_name_eq: 'atwater' },
      { names_last_name_start: 'aTw' },
      { names_last_name_cont: 'TwAt' },
      { names_first_name_eq: 'AMELIA', names_last_name_eq: 'smith' }
    ].each do |filters|
      get people_path(format: :json), params: { s: filters, from: 0, to: 100 }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.map { |row| row.dig('name', 'id') }).to eq([person.id])
    end
  end
end
