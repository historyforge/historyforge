# frozen_string_literal: true

# This translates a BuildingSearch into a format digestible by AgGrid
class BuildingGridTranslator
  include ActionView::Helpers::TextHelper

  SKIP_COLUMNS = %w[street_address id].freeze

  def initialize(search)
    @search = search
  end

  def column_def
    search.columns.reject { |col| col == 'id' }.map(&method(:column_config))
  end

  def row_data
    records.map do |record|
      hash = { street_address: { name: record.street_address, id: record.id, reviewed: record.reviewed? } }
      columns.each do |column|
        next if SKIP_COLUMNS.include?(column)

        value = record.public_send(column)
        value = truncate(strip_tags(value.to_s), escape: false) if column == 'description'
        value = truncate(value, escape: false) if column == 'annotations'
        hash[column] = value
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

  FIXED_WIDTH_COLUMNS = %w[name street_address historical_addresses description annotations].freeze
  NON_SORTABLE_COLUMNS = %w[view historical_addresses description notes annotations].freeze
  HTML_COLUMNS = %w[description historical_addresses].freeze

  def column_config(column)
    options = {
      headerName: Translator.label(Building, column),
      field: column,
      resizable: true
    }
    options[:pinned] = 'left' if column == 'street_address'
    options[:cellRenderer] = 'nameCellRenderer' if column == 'street_address'
    options[:cellRenderer] = 'htmlCellRenderer' if HTML_COLUMNS.include?(column)
    options[:width] = 200 if FIXED_WIDTH_COLUMNS.include?(column)
    options[:sortable] = true unless NON_SORTABLE_COLUMNS.include?(column)
    options
  end
end
