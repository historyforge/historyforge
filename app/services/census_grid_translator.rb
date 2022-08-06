# frozen_string_literal: true

# This translates a census record search into a format digestible by AgGrid
class CensusGridTranslator
  def initialize(search)
    @search = search
  end

  def column_def
    columns.map { |column| column_config(column) }
  end

  def row_data
    records.lazy.map do |record|
      hash = { id: record.id }
      columns.each do |column|
        value = record.public_send(column) rescue NoMethodError
        value = { name: value, reviewed: record.reviewed? } if column == 'name'
        hash[column] = value
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
    options[:headerName] = 'Actions' if column == 'id'
    options[:pinned] = 'left' if %w[id name].include?(column)
    options[:cellRenderer] = 'actionCellRenderer' if column == 'id'
    options[:cellRenderer] = 'nameCellRenderer' if column == 'name'
    options[:width] = width_for_column(column)
    options[:sortable] = true unless column == 'id'
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
    profession: 160,
    occupation: 160,
    industry: 130,
    census_scope: 160,
    name: 160,
    street_address: 160,
    notes: 160,
    coded_occupation_name: 250,
    coded_industry_name: 250
  }.freeze

  def width_for_column(column)
    COLUMN_WIDTHS[column.intern] || 80
  end
end
