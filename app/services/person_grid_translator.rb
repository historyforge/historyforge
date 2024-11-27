# frozen_string_literal: true

# This translates a census record search into a format digestible by AgGrid
class PersonGridTranslator
  SKIP_COLUMNS = %w[name id].freeze

  def initialize(search)
    @search = search
  end

  def column_def
    search.columns.reject { |col| col == 'id' }.map(&method(:column_config))
  end

  def row_data
    records.lazy.map do |record|
      name = if record.matched_last_name.present? && (record.first_name != record.matched_first_name || record.last_name != record.matched_last_name)
        matched_name = record.format_name(
          first_name: record.matched_first_name,
          last_name: record.matched_last_name
        )
        if matched_name == record.name
          record.name
        else
          "#{matched_name} (see #{record.name})"
        end
      else
        record.name
      end
      hash = { name: { name:, reviewed: record.reviewed?, id: record.id } }

      columns.each do |column|
        next if SKIP_COLUMNS.include?(column)

        value = record.public_send(column)
        if /census\d{4}/.match?(column)
          value = value.compact
          value = value.present? ? { year: column[-4...].to_i, id: value } : nil
        end
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
    options[:headerName] = column[-4...] if /census\d{4}/.match?(column)
    options[:cellRenderer] = 'nameCellRenderer' if column == 'name'
    options[:cellRenderer] = 'censusLinkCellRenderer' if /census\d{4}/.match?(column)
    options[:width] = width_for_column(column)
    options[:sortable] = true unless column == 'view'
    options
  end

  COLUMN_WIDTHS = {
    age: 50,
    sex: 60,
    marital_status: 130,
    id: 60,
    view: 60,
    occupation: 160,
    name: 300,
    description: 250
  }.freeze

  # @param column [String]
  # @return [Integer]
  def width_for_column(column)
    COLUMN_WIDTHS[column.intern] || 80
  end
end
