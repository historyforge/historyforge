# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Census coverage', type: :request do
  let(:locality) { create(:locality) }

  it 'lets administrators edit or remove one census target at a time' do
    administrator = create(:administrator)
    post user_session_path, params: { user: { email: administrator.email, password: 'b1g_sekrit' } }

    get edit_locality_path(locality)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(census_coverages_path)
    expect(Nokogiri::HTML(response.body).css('input[name*="expected_records"]')).to be_empty

    get census_coverage_locality_path(locality, year: 1910)
    expect(response).to have_http_status(:ok)
    coverage_page = Nokogiri::HTML(response.body)
    expect(coverage_page.at_css('nav[aria-label="Census years"] a[aria-current="page"]').text).to include('1910', 'Target unset')
    expect(coverage_page.css('.form-check input[type="radio"]').map { |radio| radio['value'] })
      .to eq(CensusCoverage::TARGET_BASES)

    patch update_census_coverage_locality_path(locality, year: 1910), params: {
      census_coverage: { expected_records: 14_802, target_basis: 'Published population', source: '1910 Census, Table 1' }
    }

    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(census_coverage_locality_path(locality, year: 1910))
    expect(locality.census_coverages.pluck(:census_year, :expected_records)).to eq([[1910, 14_802]])
    follow_redirect!
    expect(response.body).to include('14,802 expected')

    get census_coverages_path
    expect(response).to have_http_status(:ok)
    html = Nokogiri::HTML(response.body)
    year_index = html.css('thead th').map(&:text).index('1910')
    target_cell = html.css('tbody tr').first.element_children[year_index]
    expect(target_cell.text).to eq('0 / 14,802')
    expect(target_cell.at_css('.progress-bar.bg-success')).to be_nil
    expect(html.css('tfoot tr').first.element_children[year_index].text).to eq('14,802')
    expect(html.at_css("a[aria-label='Edit coverage for #{locality.name}']")['href']).to eq(census_coverage_locality_path(locality))

    patch update_census_coverage_locality_path(locality, year: 1910), params: {
      census_coverage: { expected_records: 0, target_basis: '', source: '' }
    }
    expect(response).to have_http_status(422)
    expect(response.body).to include('must be greater than 0')
    expect(locality.census_coverages.sole.expected_records).to eq(14_802)

    delete remove_census_coverage_locality_path(locality, year: 1910)
    expect(response).to have_http_status(:see_other)
    expect(locality.census_coverages).to be_empty
  end

  it 'marks a locality target as reached when its transcribed count exceeds the target' do
    administrator = create(:administrator)
    post user_session_path, params: { user: { email: administrator.email, password: 'b1g_sekrit' } }
    locality.census_coverages.create!(census_year: 1910, expected_records: 1,
                                      target_basis: 'Published population', source: '1910 Census, Table 1')
    create_list(:census1910_record, 2, locality:, reviewed_at: nil)

    get census_coverages_path

    completed = Nokogiri::HTML(response.body).at_css('td:has(.progress-bar.bg-success)')
    expect(completed.text).to include('Target reached.', '2 / 1')
    expect(completed.at_css('[role="progressbar"]')['aria-valuenow']).to eq('100')
  end

  it 'records manual verification below the target and preserves the published count' do
    administrator = create(:administrator)
    post user_session_path, params: { user: { email: administrator.email, password: 'b1g_sekrit' } }
    coverage = locality.census_coverages.create!(census_year: 1920, expected_records: 17_004,
                                                 target_basis: 'Published population', source: '1920 Census')
    create(:census1920_record, locality:)
    path = update_census_coverage_locality_path(locality, year: 1920)

    patch path, params: { census_coverage: { verified_complete: '1', verification_note: '' } }
    expect(response).to have_http_status(422)
    expect(coverage.reload).not_to be_verified_complete

    patch path, params: { census_coverage: { verified_complete: '1', verification_note: 'Compared with all intended schedules.' } }
    expect(response).to have_http_status(:see_other)
    expect(coverage.reload).to be_verified_complete
    expect(coverage.verified_by).to eq(administrator)
    expect(coverage.expected_records).to eq(17_004)

    get census_coverages_path
    cell = Nokogiri::HTML(response.body).at_css('td:has(.progress-bar.bg-success)')
    expect(cell.text).to include('Verified complete.', '1 / 17,004')
    expect(cell.at_css('[title]')['title']).to eq('Compared with all intended schedules.')

    get census_coverage_locality_path(locality, year: 1920)
    expect(response.body).to include('Verified on', 'Compared with all intended schedules.')

    patch path, params: { census_coverage: { verified_complete: '0' } }
    expect(response).to have_http_status(:see_other)
    expect(coverage.reload).not_to be_verified_complete
    expect(coverage.verified_by).to be_nil
    expect(coverage.verification_note).to be_nil
  end

  it 'shows review progress and recent activity for the selected locality and across all localities' do
    locality.census_coverages.create!(census_year: 1910, expected_records: 1,
                                      target_basis: 'Published population', source: '1910 Census, Table 1')
    create(:census1910_record, locality:, reviewed_at: Time.current)
    create(:census1910_record, locality:, reviewed_at: nil)
    other_locality = create(:locality)
    create(:census1910_record, locality: other_locality, reviewed_at: Time.current)

    get stats_path, params: { locality_id: locality.id }

    expect(response).to have_http_status(:ok)
    activity_rows = Nokogiri::HTML(response.body).css('.table-responsive tbody tr')
    row = activity_rows.find { |element| element.at_css('th').text == '1910' }
    expect(row.css('td').map { |cell| cell.text.strip }).to eq(%w[2 1 1 2 1])
    expect(row.at_css('[role="progressbar"]')['aria-valuenow']).to eq('50.0')
    expect(response.body).to include('Awaiting review')
    expect(response.body).not_to include('1910 Census, Table 1')

    get stats_path

    expect(response).to have_http_status(:ok)
    activity_rows = Nokogiri::HTML(response.body).css('.table-responsive tbody tr')
    row = activity_rows.find { |element| element.at_css('th').text == '1910' }
    expect(row.css('td').map { |cell| cell.text.strip }).to eq(%w[3 2 1 3 2])

    get stats_path, params: { locality_id: other_locality.id }

    activity_rows = Nokogiri::HTML(response.body).css('.table-responsive tbody tr')
    row = activity_rows.find { |element| element.at_css('th').text == '1910' }
    expect(row.text).to include('All transcribed records reviewed.')
    expect(row.at_css('.progress-bar.bg-success')).to be_present
  end
end
