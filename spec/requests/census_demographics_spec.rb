# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Census demographics', type: :request do
  before do
    allow(Setting).to receive(:census_summaries_enabled?).and_return(true)
  end

  it 'denies summary access for public censuses when summaries are disabled' do
    allow(Setting).to receive(:census_summaries_enabled?).and_return(false)

    get demographics_census1910_records_path(facet: 'race')

    expect(response).to redirect_to(root_path)
  end

  it 'allows summaries for a private census only after signing in' do
    allow(Setting).to receive(:can_view_public?).and_call_original
    allow(Setting).to receive(:can_view_public?).with(1910).and_return(false)
    allow(Setting).to receive(:can_view_private?).and_call_original
    allow(Setting).to receive(:can_view_private?).with(1910).and_return(true)
    path = demographics_census1910_records_path(facet: 'race')

    get path
    expect(response).to redirect_to(root_path)

    administrator = create(:administrator)
    post user_session_path, params: { user: { email: administrator.email, password: 'b1g_sekrit' } }

    get path
    expect(response).to have_http_status(:ok)

    allow(Setting).to receive(:can_view_private?).with(1910).and_return(false)

    get path
    expect(response).to redirect_to(root_path)
  end

  it 'uses a pie for categorical fields and a bar for age' do
    create(:census1910_record, age: 24, reviewed_at: Time.current)
    create(:census1910_record, age: 25, reviewed_at: Time.current)
    create(:census1910_record, age: 24, reviewed_at: nil)

    get demographics_census1910_records_path(facet: 'race')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Chartkick["PieChart"]')
    expect(response.body).not_to include('Chartkick["BarChart"]')

    get demographics_census1910_records_path(facet: 'age')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Chartkick["BarChart"]')
    expect(response.body).not_to include('Chartkick["PieChart"]')
    rows = Nokogiri::HTML(response.body).css('table tbody tr').to_h do |row|
      [row.at_css('th').text, row.at_css('td').text]
    end
    expect(rows).to include('15 - 19' => '0', '20 - 24' => '1', '25 - 29' => '1', 'Total' => '2')
  end

  it 'shows the selected field explanation as plain text above its charts' do
    create(:census1910_record, reviewed_at: Time.current)
    explanation = 'Values are grouped as recorded. <strong>Example</strong>'
    allow(Census1910FormFields).to receive(:options_for).and_call_original
    allow(Census1910FormFields).to receive(:options_for).with(:race).and_wrap_original do |original, field|
      original.call(field).merge(demographics_explanation: explanation)
    end

    get demographics_census1910_records_path(facet: 'race')

    expect(response).to have_http_status(:ok)
    html = Nokogiri::HTML(response.body)
    paragraph = html.at_css('p.demographics-explanation')
    expect(paragraph.text).to eq(explanation)
    expect(paragraph.element_children).to be_empty
    expect(paragraph.next_element['id']).to start_with('chart-')

    get demographics_census1910_records_path(facet: 'occupation')

    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).at_css('.demographics-explanation')).to be_nil
  end
end
