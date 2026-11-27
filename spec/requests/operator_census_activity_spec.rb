# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Operator census activity', type: :request do
  let(:operator) { create(:census_taker) }
  let(:reviewer) do
    create(:active_user).tap { |user| user.add_role Role.find_by(name: 'reviewer') }
  end

  def sign_in_as(user)
    post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } }
  end

  it 'shows an operator picker before an operator has been selected' do
    sign_in_as(reviewer)

    get operator_census_activity_path

    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    picker = page.at_css("form[action='#{operator_census_activity_path}']")
    expect(picker.at_css('input[name="creator_id"]')['value']).to be_blank
    expect(picker.at_css('input[type="search"]')['data-autocomplete-url']).to eq(creator_autocomplete_users_path(format: :json))
    expect(page.at_css('table')).to be_nil
  end

  it 'counts records for the selected operator in the current locality and links to matching census grids' do
    allow(Setting).to receive(:can_view_public?).and_return(false)
    allow(Setting).to receive(:can_view_public?).with(1910).and_return(true)
    allow(Setting).to receive(:can_view_private?).and_return(false)
    allow(Setting).to receive(:can_view_private?).with(1930).and_return(true)
    locality = create(:locality)
    census_1910 = create(:census1910_record, locality:, created_by: operator)
    census_1930 = create_list(:census1930_record, 2, locality:, created_by: operator)
    create(:census1910_record, locality:, created_by: reviewer)
    create(:census1910_record, locality: create(:locality), created_by: operator)
    create(:census1940_record, locality:, created_by: operator)
    sign_in_as(reviewer)

    get operator_census_activity_path, params: { creator_id: operator.id, locality_slug: locality.slug }

    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    expect(page.at_css('input[name="creator_id"]')['value']).to eq(operator.id.to_s)
    rows = page.css('table tbody tr')
    expect(rows.map { |row| [row.at_css('th').text, row.at_css('td').text] })
      .to eq([['1910 US Census', '1'], ['1930 US Census', '2']])

    { 1910 => [census_1910], 1930 => census_1930 }.each do |year, records|
      link = rows.css('th a').find { |anchor| anchor.text == "#{year} US Census" }
      url = URI.parse(link['href'])
      expect(url.path).to eq(census_records_path(year:))
      expect(Rack::Utils.parse_nested_query(url.query).dig('s', 'creator_id')).to eq(operator.id.to_s)

      get "#{url.path}.json?#{url.query}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.pluck('id')).to match_array(records.map(&:id))
    end
  end

  it 'denies guests and census takers access to operator activity' do
    get operator_census_activity_path, params: { creator_id: operator.id }
    expect(response).to redirect_to(root_path)

    sign_in_as(operator)
    get operator_census_activity_path, params: { creator_id: operator.id }
    expect(response).to redirect_to(root_path)
  end

  it 'returns 404 for an unknown operator' do
    sign_in_as(reviewer)

    get operator_census_activity_path, params: { creator_id: reviewer.id + 1 }

    expect(response).to have_http_status(:not_found)
  end
end
