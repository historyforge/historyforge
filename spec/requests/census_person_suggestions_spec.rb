# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Census person suggestions', type: :request do
  include Devise::Test::IntegrationHelpers

  it 'shows the name evidence on the suggestion beside the manual match action' do
    sign_in create(:administrator)
    candidate = create(:person, first_name: 'Purl', middle_name: 'R', last_name: 'Leonard', sex: 'M', birth_year: 1870)
    create(:census1920_record, person: candidate, age: 50)
    record = create(:census1900_record, first_name: 'Perl', last_name: 'Leonard', sex: 'M', age: 30)

    get polymorphic_path(record)

    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    match = page.at_css(".list-group-item:has(a[href='#{person_path(candidate)}'])")
    expect(match.text).to include('Known nickname and same surname')
    expect(match.at_css('input[name="census_record[person_id]"]')['value']).to eq(candidate.id.to_s)
    expect(record.reload.person_id).to be_nil
  end
end
