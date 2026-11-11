# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Census demographics', type: :request do
  it 'shows the selected field explanation as plain text above its charts' do
    create(:census1910_record, reviewed_at: Time.current)
    allow(Setting).to receive(:can_view_public_demographics?).with(1910).and_return(true)
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
