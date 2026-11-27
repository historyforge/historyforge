# frozen_string_literal: true

require 'csv'

module CensusSummaries
  class CsvExport
    def initialize(report)
      @report = report
    end

    def generate
      statistics = @report.statistics
      locality_names = @report.localities.map(&:name)
      denominator = statistics[:included]
      filters = @report.search_params.fetch(:s, {}).except('locality_id_in')
      context = [
        @report.year, @report.field, Translator.filter(@report.search.entity_class, @report.field), spreadsheet_text(locality_names.to_sentence),
        @report.search_params[:scope], @report.review_status,
        filters.to_json, statistics[:matching], denominator, statistics[:blank],
        statistics[:unknown], statistics[:outside_range], statistics[:conditional],
        @report.localities.count { |locality| @report.coverage_targets.key?(locality.id) },
        @report.localities.size
      ]

      CSV.generate do |csv|
        csv << %w[census_year field field_label localities search_scope record_access filters_json
                  matching_records included_records blank_records unknown_records outside_chart_range
                  conditional_field localities_with_coverage_targets locality_count recorded_value records
                  percent_of_included]
        if denominator.zero?
          csv << context
        else
          statistics[:rows].each do |label, count|
            csv << [*context, spreadsheet_text(label), count, (count.fdiv(denominator) * 100).round(2)]
          end
        end
      end
    end

    private

    def spreadsheet_text(value)
      return value unless value.is_a?(String) && value.match?(/\A(?:[\t\r\n]|[[:space:]]*[=+\-@])/)

      "'#{value}"
    end
  end
end
