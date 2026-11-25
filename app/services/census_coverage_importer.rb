# frozen_string_literal: true

require 'csv'
require 'set'

class CensusCoverageImporter
  HEADERS = %w[locality_slug census_year expected_records target_basis source scope_note].freeze

  def self.template(localities)
    CSV.generate do |csv|
      csv << ['locality_name', *HEADERS]
      localities.each do |slug, name|
        spreadsheet_name = name.match?(/\A[\s\uFEFF]*[=+@-]/) ? "'#{name}" : name
        CensusYears.each { |year| csv << [spreadsheet_name, slug, year, nil, nil, nil, nil] }
      end
    end
  end

  def initialize(path)
    @path = path
  end

  def import(apply: false)
    table = CSV.read(@path, headers: true, encoding: 'bom|utf-8')
    missing = HEADERS - table.headers
    raise ArgumentError, "Missing CSV columns: #{missing.join(', ')}" if missing.any?
    raise ArgumentError, 'Duplicate CSV column names' unless table.headers.uniq == table.headers

    rows = table.map.with_index(2) do |row, number|
      [number, HEADERS.index_with { |key| row[key]&.strip.presence }]
    end
    seen = Set.new
    counts = { created: 0, updated: 0, unchanged: 0, skipped: 0 }
    CensusCoverage.transaction(requires_new: true) do
      slugs = rows.map { |_, row| row.fetch('locality_slug') }.compact.uniq
      localities = Locality.where(slug: slugs).reorder(:id).lock.index_by(&:slug)
      rows.each do |number, row|
        status = import_row(row, number, localities, seen, apply:)
        counts[status] += 1
      end
    end
    counts
  rescue CSV::MalformedCSVError => error
    raise ArgumentError, error.message
  end

  private

  def import_row(row, number, localities, seen, apply:)
    slug, year = row.values_at('locality_slug', 'census_year')
    locality = localities[slug]
    raise ArgumentError, "Row #{number}: unknown locality #{slug.inspect}" unless locality
    unless year&.match?(/\A\d{4}\z/) && CensusYears::YEARS.include?(year.to_i)
      raise ArgumentError, "Row #{number}: unsupported census year #{year.inspect}"
    end
    raise ArgumentError, "Row #{number}: duplicate locality and census year" unless seen.add?([slug, year])

    attributes = row.except('locality_slug', 'census_year')
    return :skipped if attributes.values.all?(&:nil?)

    coverage = locality.census_coverages.find_or_initialize_by(census_year: year.to_i)
    coverage.assign_attributes(attributes)
    status = coverage.new_record? ? :created : (coverage.changed? ? :updated : :unchanged)
    apply ? coverage.save! : coverage.validate!
    status
  rescue ActiveRecord::RecordInvalid => error
    raise ArgumentError, "Row #{number}: #{error.record.errors.full_messages.to_sentence}"
  end
end
