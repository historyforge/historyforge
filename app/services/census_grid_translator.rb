# frozen_string_literal: true

# This translates a BuildingSearch into a format digestible by AgGrid
class CensusGridTranslator
  def initialize(search)
    @search = search
  end

  def column_def
    columns.map { |column| column_config(column) }.to_json.html_safe
  end

  def row_data
    records.map do |record|
      hash = { id: record.id }
      columns.each do |column|
        value = record.field_for(column)
        value = { name: value, reviewed: record.reviewed? } if column == 'name'
        hash[column] = value
      end
      hash
    end.to_json.html_safe
  end

  private

  attr_reader :search

  delegate :columns, :entity_class, to: :search

  def records
    search.results
  end

  def column_config(column)
    options = {
      headerName: translated_label(column),
      field: column,
      resizable: true
    }
    options[:headerName] = 'Actions' if column == 'id'
    options[:pinned] = 'left' if %w[id name].include?(column)
    options[:cellRenderer] = 'actionCellRenderer' if column == 'id'
    options[:cellRenderer] = 'nameCellRenderer' if column == 'name'
    options[:width] = 50 if %w[page_number page_side line_number age sex marital_status].include?(column)
    options[:width] = 60 if %w[id ward enum_dist dwelling_number family_id].include?(column)
    options[:width] = 130 if %w[marital_status profession industry].include?(column)
    options[:width] = 160 if %w[census_scope name street_address notes profession].include?(column)
    options[:width] = 250 if %w[coded_occupation_name coded_industry_name].include?(column)
    options[:sortable] = true unless column == 'id'
    options
  end

  def translated_label(key)
    Translator.label(entity_class, key)
  end
end
