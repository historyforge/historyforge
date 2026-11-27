# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Census summaries', type: :request do
  before do
    allow(Setting).to receive(:census_summaries_enabled?).and_return(true)
    allow(Setting).to receive(:can_view_public?).and_return(false)
    allow(Setting).to receive(:can_view_public?).with(1910).and_return(true)
  end

  it 'denies summary access for public censuses when summaries are disabled' do
    allow(Setting).to receive(:census_summaries_enabled?).and_return(false)

    get census_summary_path(year: 1910, facet: 'race')

    expect(response).to redirect_to(root_path)
  end

  it 'allows summaries for a private census only after signing in' do
    allow(Setting).to receive(:can_view_public?).with(1910).and_return(false)
    allow(Setting).to receive(:can_view_private?).and_call_original
    allow(Setting).to receive(:can_view_private?).with(1910).and_return(true)
    path = census_summary_path(year: 1910, facet: 'race')

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

  it 'switches years with the selected summary field and compatible filters' do
    allow(Setting).to receive(:can_view_public?).with(1920).and_return(true)
    allow(Setting).to receive(:can_view_public?).with(1950).and_return(true)
    locality = create(:locality)
    settings = { locality_id_in: [locality.id], race_in: ['Mu'], sex_in: ['F'], page_number_eq: '2',
                 ward_eq: '', creation_date_range: 'all' }
    get census_summary_path(year: 1910, facet: 'race', s: settings, scope: 'on')

    nav = Nokogiri::HTML(response.body).at_css('nav[aria-label="Census summary years"]')
    jump = nav.css('.dropdown-item[href]').find { |link| link.text == '1950' }['href']
    expect(URI.parse(jump).path).to eq('/census/1950/summary')
    expect(nav.at_css('[rel="next"]').text).to include('1920')
    expect(nav.text).not_to include('1930')
    query = Rack::Utils.parse_nested_query(URI.parse(jump).query)
    expect(query['facet']).to eq('race')
    expect(query['s']).to eq('locality_id_in' => [locality.id.to_s], 'sex_in' => ['F'])
    expect(query['omitted_filters']).to eq('2')
    expect(query).not_to have_key('scope')

    get jump

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('2 filters did not carry over to 1950.')
    expect(Nokogiri::HTML(response.body).at_css('#facet option[selected]')['value']).to eq('race')
  end

  it 'omits enabled years that lack the selected field' do
    allow(Setting).to receive(:can_view_public?).with(1920).and_return(true)

    get census_summary_path(year: 1910, facet: 'language_spoken')

    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).at_css('nav[aria-label="Census summary years"]')).to be_nil
    expect(response.body).to include('Language Spoken is only available in 1910 among enabled summaries.')
    expect(response.body).to include('people age 10 or older who could speak English')
  end

  it 'names the selected locality and carries it into year links without changing the site locality' do
    allow(Setting).to receive(:can_view_public?).with(1920).and_return(true)
    city = create(:locality, name: 'City of Ithaca')
    town = create(:locality, name: 'Town of Caroline')
    create(:census1910_record, locality: city, race: 'B', reviewed_at: Time.current)
    create(:census1910_record, locality: town, race: 'W', reviewed_at: Time.current)

    get census_summary_path(year: 1910, facet: 'race', locality_slug: city.slug)
    html = Nokogiri::HTML(response.body)
    expect(html.at_css('h1').text).to eq('1910 Census Record Summaries for City of Ithaca')
    expect(html.at_css('#summary_locality')).to be_nil

    get census_summary_path(year: 1910, facet: 'race', summary_locality: town.id)
    html = Nokogiri::HTML(response.body)
    expect(html.at_css('h1').text).to eq('1910 Census Record Summaries for Town of Caroline')
    expect(html.css('table tbody th').map(&:text)).to eq(['White'])
    jump = html.at_css('nav[aria-label="Census summary years"] [rel="next"]')['href']
    expect(Rack::Utils.parse_nested_query(URI.parse(jump).query).dig('s', 'locality_id_in')).to eq([town.id.to_s])

    get census_summary_path(year: 1910, facet: 'race', summary_locality: 'all')
    html = Nokogiri::HTML(response.body)
    expect(html.at_css('h1').text).to eq('1910 Census Record Summaries')
    expect(html.css('table tbody th').map(&:text)).to contain_exactly('White', 'Black')

    get census_summary_path(year: 1910, facet: 'race')
    html = Nokogiri::HTML(response.body)
    expect(html.at_css('h1').text).to eq('1910 Census Record Summaries for City of Ithaca')
    shortcut = html.css('#main-header a').find { |link| link.text == 'Census Summaries' }
    expect(URI.parse(shortcut['href']).path).to eq('/census/1920/summary')

    get census_summary_path(year: 1910, facet: 'race', locality_slug: city.slug, s: { locality_id_in: [city.id] })
    header = Nokogiri::HTML(response.body).at_css('#main-header')
    switch = header.css('a').find { |link| link.text == town.short_name }
    put switch['href']
    follow_redirect!
    html = Nokogiri::HTML(response.body)
    expect(html.at_css('h1').text).to eq('1910 Census Record Summaries for Town of Caroline')
    expect(html.css('table tbody th').map(&:text)).to eq(['White'])
  end

  it 'preserves grid filters and reports the chart denominator separately from locality coverage' do
    locality = create(:locality)
    locality.census_coverages.create!(census_year: 1910, expected_records: 5,
                                      target_basis: 'Published population', source: 'Census Table 1')
    other_locality = create(:locality)
    create(:census1910_record, locality:, sex: 'F', race: 'B', reviewed_at: Time.current)
    create(:census1910_record, locality:, sex: 'F', race: 'unknown', reviewed_at: Time.current)
    create(:census1910_record, locality:, sex: 'F', race: nil, reviewed_at: Time.current)
    create(:census1910_record, locality:, sex: 'M', race: 'W', reviewed_at: Time.current)
    create(:census1910_record, locality:, sex: 'F', race: 'W', reviewed_at: nil)
    create(:census1910_record, locality: other_locality, sex: 'M', reviewed_at: Time.current)
    filters = { sex_in: ['F'] }

    get census_records_path(year: 1910), params: { s: filters }
    html = Nokogiri::HTML(response.body)
    summary_url = html.css('a').find { |link| link.text == 'Summarize Records' }['href']
    expect(Rack::Utils.parse_nested_query(URI.parse(summary_url).query)['s']).to eq('sex_in' => ['F'])

    get summary_url, params: { from: 0, to: 1 }
    expect(response).to have_http_status(:ok)
    html = Nokogiri::HTML(response.body)
    expect(html.text).to include('5 transcribed / 5 expected', '4 reviewed', 'Census Table 1', 'Coverage unknown')
    totals = html.css('table tfoot tr').to_h { |row| [row.at_css('th').text, row.at_css('td').text] }
    expect(totals).to eq('Included in chart' => '1', 'Blank' => '1', 'Unknown' => '1', 'Matching records' => '3')
    chart = html.at_css('[id^="chart-"]')
    disclosure = html.css('details').find { |section| section.at_css('summary')&.text == 'About these results' }
    expect(chart <=> disclosure).to eq(-1)
    expect(html.at_css('table') <=> disclosure).to eq(-1)
    expect(disclosure['open']).to be_nil
    source = disclosure.at_css('details')
    expect(source['open']).to be_nil
    expect(source.at_css('summary').text).to include(locality.name, '5 transcribed / 5 expected')
    expect(source.text).to include('Census Table 1')
    expect(html.at_css('input[name="s[sex_in][]"]')['value']).to eq('F')
    csv = html.css('a').find { |link| link.text == 'Download matching records' }['href']
    csv_params = Rack::Utils.parse_nested_query(URI.parse(csv).query)
    expect(csv_params['s']).to eq('sex_in' => ['F'])
    expect(csv_params['f']).to include('race')
    get csv
    expect(CSV.parse(response.body, headers: true).size).to eq(3)

    summary_csv = html.css('a').find { |link| link.text == 'Download CSV' }['href']
    get summary_csv

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('text/csv')
    export = CSV.parse(response.body, headers: true)
    expect(export.size).to eq(1)
    expect(export.first.to_h).to include(
      'census_year' => '1910', 'field' => 'race', 'filters_json' => '{"sex_in":["F"]}',
      'matching_records' => '3', 'included_records' => '1', 'blank_records' => '1',
      'unknown_records' => '1', 'records' => '1', 'percent_of_included' => '100.0',
      'localities_with_coverage_targets' => '1', 'locality_count' => '2'
    )
  end

  it 'shows an ordered age distribution and counts unknown ages outside the denominator' do
    create(:census1910_record, age: 24, reviewed_at: Time.current)
    create(:census1910_record, age: 25, reviewed_at: Time.current)
    create(:census1910_record, age: 999, reviewed_at: Time.current)
    create(:census1910_record, age: nil, age_months: 7, reviewed_at: Time.current)
    create(:census1910_record, age: 1, age_months: 3, reviewed_at: Time.current)
    create(:census1910_record, age: nil, age_months: 12, reviewed_at: Time.current)

    get census_summary_path(year: 1910, facet: 'age_months')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('An exploratory summary.', 'Chartkick["BarChart"]')
    expect(response.body).not_to include('Transcription coverage</h2>', 'Set up census coverage')
    html = Nokogiri::HTML(response.body)
    expect(html.at_css('#facet option[selected]')['value']).to eq('age')
    expect(html.at_css('#facet option[value="age_months"]')).to be_nil
    rows = html.css('table tbody tr').to_h do |row|
      [row.at_css('th').text, row.at_css('td').text]
    end
    expect(rows.keys.first(3)).to eq(['Under 1 year', '1 - 4', '5 - 9'])
    expect(rows).to include('Under 1 year' => '1', '1 - 4' => '2', '20 - 24' => '1', '25 - 29' => '1', '135 - 139' => '0')
    totals = html.css('table tfoot tr').to_h { |row| [row.at_css('th').text, row.at_css('td').text] }
    expect(totals).to eq('Included in chart' => '5', 'Unknown' => '1', 'Matching records' => '6')
    csv = html.css('a').find { |link| link.text == 'Download matching records' }['href']
    expect(Rack::Utils.parse_nested_query(URI.parse(csv).query)['f']).to include('age', 'age_months')
  end

  it 'shows administrators a coverage setup link when there are no targets for this census' do
    allow(Setting).to receive(:can_view_private?).and_return(false)
    allow(Setting).to receive(:can_view_private?).with(1910).and_return(true)
    administrator = create(:administrator)
    post user_session_path, params: { user: { email: administrator.email, password: 'b1g_sekrit' } }

    get census_summary_path(year: 1910, facet: 'race')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Only this census year has summaries available.',
                                     'Enable access to another census year in Settings')
    notice = Nokogiri::HTML(response.body).at_css('.alert-secondary')
    expect(notice.text).to include('An exploratory summary.')
    setup_link = Nokogiri::HTML(response.body).css('a').find { |link| link.text == 'Set up census coverage' }
    expect(setup_link['href']).to eq(census_coverages_path)
    expect(setup_link.parent.text).to include('where the expected counts came from.')
  end

  it 'rejects unsupported summary fields' do
    get census_summary_path(year: 1910, facet: 'id')
    expect(response).to have_http_status(:bad_request)
  end

  it 'shows birth months in calendar order and accounts for the unknown code at the end' do
    allow(Setting).to receive(:can_view_public?).with(1900).and_return(true)
    create_list(:census1900_record, 2, birth_month: 12, reviewed_at: Time.current)
    create(:census1900_record, birth_month: 1, reviewed_at: Time.current)
    create(:census1900_record, reviewed_at: Time.current).update_column(:birth_month, 999)

    get census_summary_path(year: 1900, facet: 'birth_month')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Chartkick["BarChart"]')
    html = Nokogiri::HTML(response.body)
    rows = html.css('table tbody tr').to_h { |row| [row.at_css('th').text, row.at_css('td').text] }
    expect(rows.keys).to eq(Date::MONTHNAMES.compact)
    expect(rows).to include('January' => '1', 'February' => '0', 'December' => '2')
    totals = html.css('table tfoot tr').to_h { |row| [row.at_css('th').text, row.at_css('td').text] }
    expect(totals).to eq('Included in chart' => '3', 'Unknown' => '1', 'Matching records' => '4')
  end

  it 'omits the field description for a self-explanatory field' do
    create(:census1910_record, sex: 'F', reviewed_at: Time.current)

    get census_summary_path(year: 1910, facet: 'sex')

    expect(response).to have_http_status(:ok)
    html = Nokogiri::HTML(response.body)
    expect(html.at_css('#facet option[selected]')['value']).to eq('sex')
    expect(html.at_css('.summary-field-description')).to be_nil
  end

  it 'shows 1900 school attendance in month order with blanks and outliers accounted for' do
    allow(Setting).to receive(:can_view_public?).with(1900).and_return(true)
    [9, 9, 0, 99, nil].each do |months|
      create(:census1900_record, attended_school: months, reviewed_at: Time.current)
    end

    get census_summary_path(year: 1900, facet: 'attended_school')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Months of School Attendance', 'Chartkick["BarChart"]')
    html = Nokogiri::HTML(response.body)
    hint = html.at_css('p.summary-field-description')
    expect(hint.text).to include('Months of school attendance during the year ending June 1, 1900.')
    rows = html.css('table tbody tr').to_h { |row| [row.at_css('th').text, row.at_css('td').text] }
    expect(rows.keys).to eq((0..12).map(&:to_s))
    expect(rows).to include('0' => '1', '9' => '2')
    totals = html.css('table tfoot tr').to_h { |row| [row.at_css('th').text, row.at_css('td').text] }
    expect(totals).to eq('Included in chart' => '3', 'Blank' => '1', 'Outside the chart range' => '1', 'Matching records' => '5')
  end

  it 'orders counts numerically, text alphabetically, and education codes by grade' do
    [10, 10, 2].zip(%w[Teacher Teacher Baker]).each do |years, occupation|
      create(:census1910_record, years_married: years, occupation:, reviewed_at: Time.current)
    end
    get census_summary_path(year: 1910, facet: 'years_married')
    expect(Nokogiri::HTML(response.body).css('tbody th').map(&:text)).to eq(%w[2 10])

    get census_summary_path(year: 1910, facet: 'occupation')
    expect(Nokogiri::HTML(response.body).css('tbody th').map(&:text)).to eq(%w[Baker Teacher])

    allow(Setting).to receive(:can_view_public?).with(1940).and_return(true)
    %w[C-1 H-1 8].each { |grade| create(:census1940_record, grade_completed: grade, reviewed_at: Time.current) }
    get census_summary_path(year: 1940, facet: 'grade_completed')
    expect(Nokogiri::HTML(response.body).css('tbody th').map(&:text)).to eq(['8', 'H-1 or 9', 'C-1'])
  end

  it 'explains why blanks in a supplemental field cannot be treated as missing answers' do
    allow(Setting).to receive(:can_view_public?).with(1950).and_return(true)
    get census_summary_path(year: 1950, facet: 'highest_grade')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('This field was asked only of certain people.')
    expect(response.body).to include('No matching records have a usable value for this field.')
  end

  it 'shows the selected field explanation as plain text above its charts' do
    create(:census1910_record, reviewed_at: Time.current)
    explanation = 'Values are grouped as recorded. <strong>Example</strong>'
    allow(Census1910FormFields).to receive(:options_for).and_call_original
    allow(Census1910FormFields).to receive(:options_for).with(:race).and_wrap_original do |original, field|
      original.call(field).merge(demographics_explanation: explanation)
    end

    get census_summary_path(year: 1910, facet: 'race')

    expect(response).to have_http_status(:ok)
    html = Nokogiri::HTML(response.body)
    paragraph = html.at_css('p.demographics-explanation')
    expect(paragraph.text).to eq(explanation)
    expect(paragraph.element_children).to be_empty
    expect(paragraph.next_element['id']).to start_with('chart-')

    get census_summary_path(year: 1910, facet: 'occupation')

    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).at_css('.demographics-explanation')).to be_nil
  end

  it 'shows the selected field explanation as plain text above its charts' do
    create(:census1910_record, reviewed_at: Time.current)
    explanation = 'Values are grouped as recorded. <strong>Example</strong>'
    allow(Census1910FormFields).to receive(:options_for).and_call_original
    allow(Census1910FormFields).to receive(:options_for).with(:race).and_wrap_original do |original, field|
      original.call(field).merge(demographics_explanation: explanation)
    end

    get census_summary_path(year: 1910, facet: 'race')

    expect(response).to have_http_status(:ok)
    html = Nokogiri::HTML(response.body)
    paragraph = html.at_css('p.demographics-explanation')
    expect(paragraph.text).to eq(explanation)
    expect(paragraph.element_children).to be_empty
    expect(paragraph.next_element['id']).to start_with('chart-')

    get census_summary_path(year: 1910, facet: 'occupation')

    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).at_css('.demographics-explanation')).to be_nil
  end
end
