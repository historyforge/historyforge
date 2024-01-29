# frozen_string_literal: true

# This translates a census record search into a format digestible by AgGrid
class CensusGridTranslator
  SKIP_COLUMNS = %w[name id].freeze

  def initialize(search)
    @search = search
  end

  def column_def
    columns.reject { |col| col == 'id' }.map { |column| column_config(column) }
  end

  def row_data
    records.lazy.map do |record|
      hash = { name: { name: record.name, reviewed: record.reviewed?, id: record.id } }
      columns.each do |column|
        next if SKIP_COLUMNS.include?(column)

        hash[column] = record.public_send(column)
      rescue NoMethodError
        # sometimes people manipulate URLs to include fields that don't exist
        # we just ignore because it's not a symptom of anything wrong here just
        # people being clever
      end
      hash
    end
  end

  private

  attr_reader :search

  delegate :columns, :entity_class, to: :search

  def records
    search.results
  end

  def column_config(column)
    options = {
      headerName: Translator.label(entity_class, column),
      field: column,
      resizable: true
    }
    options[:headerName] = column[-4...] if /census\d{4}/.match?(column)
    options[:pinned] = 'left' if column == 'name'
    options[:cellRenderer] = 'nameCellRenderer' if column == 'name'
    options[:width] = width_for_column(column)
    options[:sortable] = true
    options
  end

  COLUMN_WIDTHS = {
    page_number: 50,
    page_side: 50,
    line_number: 50,
    age: 50,
    sex: 60,
    marital_status: 130,
    id: 60,
    ward: 60,
    enum_dist: 60,
    dwelling_number: 60,
    family_id: 60,
    occupation: 160,
    industry: 130,
    census_scope: 160,
    name: 160,
    street_address: 160,
    notes: 160,
    coded_occupation_name: 250,
    coded_industry_name: 250,
    institution_name: 130,
    institution_type: 130
  }.freeze

  def width_for_column(column)
    COLUMN_WIDTHS[column.intern] || 80
  end
end
