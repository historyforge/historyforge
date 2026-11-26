# frozen_string_literal: true

require 'rails_helper'
require 'tempfile'

RSpec.describe CensusCoverageImporter do
  let!(:locality) { create(:locality) }

  def with_csv(*rows)
    Tempfile.create(['census-coverage', '.csv']) do |file|
      file.write(CSV.generate_line(described_class::HEADERS))
      rows.each { |row| file.write(CSV.generate_line(row)) }
      file.flush
      yield described_class.new(file.path)
    end
  end

  it 'previews changes, skips empty targets, and can be rerun after applying' do
    row = [locality.slug, 1910, 1_646, 'Published population', '1910 Census, Table 1', nil]
    with_csv(row, [locality.slug, 1920]) do |importer|
      expect(importer.import).to eq(created: 1, updated: 0, unchanged: 0, skipped: 1)
      expect(CensusCoverage.count).to eq(0)
      expect(importer.import(apply: true)).to eq(created: 1, updated: 0, unchanged: 0, skipped: 1)
      expect(importer.import(apply: true)).to eq(created: 0, updated: 0, unchanged: 1, skipped: 1)
    end

    with_csv([locality.slug, 1910, 1_647, 'Schedule count', 'Counted from population schedules', 'Whole town']) do |importer|
      expect(importer.import(apply: true)).to eq(created: 0, updated: 1, unchanged: 0, skipped: 0)
    end
    expect(locality.census_coverages.sole.expected_records).to eq(1_647)
  end

  it 'rejects duplicate keys and rolls back earlier rows' do
    row = [locality.slug, 1910, 1_646, 'Published population', '1910 Census, Table 1']
    with_csv(row, row) do |importer|
      expect { importer.import(apply: true) }.to raise_error(ArgumentError, /Row 3: duplicate/)
      expect(CensusCoverage.count).to eq(0)
    end
  end

  it 'reports incomplete targets by row' do
    with_csv([locality.slug, 1910, 1_646]) do |importer|
      expect { importer.import(apply: true) }.to raise_error(ArgumentError, /Row 2:.*Source/)
      expect(CensusCoverage.count).to eq(0)
    end
  end
end
