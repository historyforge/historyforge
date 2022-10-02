# frozen_string_literal: true

# This translates a BuildingSearch into a format digestible by AgGrid
class BuildingGridTranslator
  include ActionView::Helpers::TextHelper

  def initialize(search)
    @search = search
  end

  def column_def
    columns = search.columns
    columns << 'view'
    columns.map { |column| column_config(column) }
  end

  def row_data
    records.map do |record|
      hash = { id: record.id }
      columns.each do |column|
        value = record.public_send(column)
        value = { name: value, reviewed: record.reviewed? } if column == 'street_address'
        value = truncate(strip_tags(value.to_s), escape: false) if column == 'description'
        value = truncate(value, escape: false) if column == 'annotations'
        hash[column] = value
        hash['view'] = { id: record.id } if column == 'street_address'
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

  delegate :columns, to: :search

  def records
    search.results
  end

  def column_config(column)
    options = {
      headerName: Translator.label(Building, column),
      field: column,
      resizable: true
    }
    options[:headerName] = 'Actions' if column == 'view'
    options[:pinned] = 'left' if %w[id street_address].include?(column)
    options[:pinned] = 'right' if column == 'view'
    options[:cellRenderer] = 'actionCellRenderer' if column == 'view'
    options[:cellRenderer] = 'nameCellRenderer' if column == 'street_address'
    options[:cellRenderer] = 'htmlCellRenderer' if column == 'description' || column == 'historical_addresses'
    options[:width] = 200 if %w[name street_address historical_addresses description annotations].include?(column)
    options[:sortable] = true unless %w{view historical_addresses description notes annotations}.include?(column)
    options
  end
end
