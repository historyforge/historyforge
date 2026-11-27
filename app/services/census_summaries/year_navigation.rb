# frozen_string_literal: true

module CensusSummaries
  class YearNavigation
    attr_reader :destinations

    def initialize(report, available_years, &creator_search_scope)
      @report = report
      @available_years = available_years
      @creator_search_scope = creator_search_scope
      @destinations = available_years.filter_map do |year|
        next [year, nil] if year == report.year

        config = "Census#{year}FormFields".constantize
        next if report.field && !config.facets.include?(report.field.to_sym)

        [year, summary_year_params(year, config)]
      end.to_h
    end

    def other_years_available?
      @available_years.any? { |year| year != @report.year }
    end

    private

    def summary_year_params(candidate, config)
      record_class = CensusYears.class_for(candidate)
      current_filters = @report.search_params.fetch(:s, {})
      filters = transferable_summary_filters(config, current_filters)
      if @creator_search_scope.call(record_class)
        filters.merge!(current_filters.slice(*CreatorFilter::PARAM_KEYS))
      end
      @report.search_params.except(:s).merge(
        year: candidate, s: filters.presence, facet: @report.field,
        omitted_filters: (current_filters.size - filters.size).nonzero?
      ).compact
    end

    def transferable_summary_filters(config, current_filters)
      return {} if current_filters.empty?

      fields = CensusFiltersGenerator.generate(Jbuilder.new, config).attributes!
      fields.except('page_number', 'page_side', 'line_number', 'ward', 'enum_dist', 'dwelling_number', 'family_id')
            .each_value
            .each_with_object({}) do |field, filters|
        field.fetch('scopes', {}).each_key do |predicate|
          value = current_filters[predicate]
          next if value.blank?

          choices = field['choices']
          allowed_values = choices&.map { |choice| Array(choice).last.to_s }
          filters[predicate] = value if !allowed_values || (Array(value).map(&:to_s) - allowed_values).empty?
        end
      end
    end
  end
end
