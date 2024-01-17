# frozen_string_literal: true

# This translates a census record search into a format digestible by AgGrid
class PersonGridTranslator
  def initialize(search)
    @search = search
  end

  def column_def
    search.columns.map(&method(:column_config))
  end

  def row_data
    records.lazy.map do |record|
      hash = { id: record.id }
      columns.each do |column|
        value = record.public_send(column)
        if column == 'name'
          if record.matched_last_name.present?
            matched_name = record.format_name(
              first_name: record.matched_first_name,
              middle_name: record.matched_middle_name,
              last_name: record.matched_last_name,
              name_prefix: record.matched_name_prefix,
              name_suffix: record.matched_name_suffix
            )
            name = matched_name == value ? value : "#{matched_name} (see #{value})"
            value = { name:, reviewed: record.reviewed? }
          else
            value = { name: value, reviewed: record.reviewed? }
          end
        end
        if column =~ /census\d{4}/
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
    options[:headerName] = column[-4...] if column =~ /census\d{4}/
    options[:pinned] = 'left' if %w[id name].include?(column)
    options[:cellRenderer] = 'actionCellRenderer' if column == 'id'
    options[:cellRenderer] = 'nameCellRenderer' if column == 'name'
    options[:cellRenderer] = 'censusLinkCellRenderer' if column =~ /census\d{4}/
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

  def width_for_column(column)
    COLUMN_WIDTHS[column.intern] || 80
  end
end
