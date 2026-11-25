# frozen_string_literal: true

require 'rails_helper'
require 'tempfile'

RSpec.describe 'Census coverage import', type: :request do
  let!(:locality) { create(:locality) }

  def sign_in_administrator
    administrator = create(:administrator)
    post user_session_path, params: { user: { email: administrator.email, password: 'b1g_sekrit' } }
  end

  def upload_csv(*rows)
    Tempfile.create(['coverage', '.csv']) do |file|
      file.write(CSV.generate_line(CensusCoverageImporter::HEADERS))
      rows.each { |row| file.write(CSV.generate_line(row)) }
      file.flush
      post import_census_coverage_localities_path, params: {
        file: Rack::Test::UploadedFile.new(file.path, 'text/csv')
      }
    end
  end

  it 'links to the upload page and downloads a blank template for the database localities' do
    sign_in_administrator
    another_locality = create(:locality, name: 'Town of Caroline')

    get census_coverages_path
    expect(response.body).to include(census_coverage_import_localities_path)

    get census_coverage_import_localities_path
    expect(response).to have_http_status(:ok)
    html = Nokogiri::HTML(response.body)
    expect(html.at_css('input[type="file"]')['name']).to eq('file')
    prompt = html.at_css('textarea[readonly]').text
    expect(prompt).to include('Published population', 'scope_note', CensusYears::YEARS.join(', '))
    expect(prompt).to include("#{locality.name} (`#{locality.slug}`)", 'Town of Caroline (`town-of-caroline`)')

    get census_coverage_template_localities_path
    expect(response.media_type).to eq('text/csv')
    rows = CSV.parse(response.body, headers: true)
    expect(rows.headers).to eq(['locality_name', *CensusCoverageImporter::HEADERS])
    expected_rows = [locality, another_locality].flat_map do |record|
      CensusYears::YEARS.map { |year| [record.name, record.slug, year.to_s] }
    end
    expect(rows.map { |row| row.fields('locality_name', 'locality_slug', 'census_year') })
      .to match_array(expected_rows)
    expect(rows['expected_records']).to all(be_nil)
  end

  it 'imports valid CSVs and reports row errors without saving partial changes' do
    sign_in_administrator
    target = [locality.slug, 1910, 1_646, 'Published population', '1910 Census, Table 1']
    upload_csv(target, [locality.slug, 1920])
    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(census_coverage_import_localities_path)
    follow_redirect!
    expect(response.body).to include('Import complete.', '1 created', '1 skipped')
    expect(locality.census_coverages.sole.expected_records).to eq(1_646)

    upload_csv([locality.slug, 1900, 1_938, 'Published population', '1910 Census, Table 1'], ['unknown', 1910])
    expect(response).to have_http_status(422)
    expect(response.body).to include('Row 3', 'unknown locality')
    expect(locality.census_coverages.pluck(:census_year)).to eq([1910])
  end

  it 'requires administrator access to download a template or import targets' do
    get census_coverage_template_localities_path
    expect(response).not_to have_http_status(:ok)

    upload_csv([locality.slug, 1910, 1_646, 'Published population', '1910 Census, Table 1'])
    expect(response).not_to have_http_status(:ok)
    expect(CensusCoverage.count).to eq(0)
  end
end
