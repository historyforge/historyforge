# frozen_string_literal: true

module CensusRecords
  class SummariesController < ApplicationController
    prepend_before_action :check_access

    def show
      authorize! :read, resource_class
      @report = CensusSummaries::Report.new(
        year:, params: params.permit!.to_h, user: current_user, creator_scope: creator_search_scope(resource_class)
      )
      @page_title = @report.title
      if request.format.csv?
        return head :bad_request unless @report.statistics

        return send_data CensusSummaries::CsvExport.new(@report).generate,
                         filename: "historyforge-#{year}-#{@report.field}-summary.csv", type: 'text/csv; charset=utf-8'
      end

      available_years = CensusYears::YEARS.select { |candidate| can_view_census_summary?(candidate) }
      @year_navigation = CensusSummaries::YearNavigation.new(@report, available_years, &method(:creator_search_scope))
    rescue CensusSummaries::Report::InvalidSelection
      head :bad_request
    end

    def summary_locality_return_path
      census_summary_path(@report.locality_return_params.symbolize_keys) if @report
    end

    def summary_locality_id
      @report&.locality_id
    end
    helper_method :summary_locality_return_path, :summary_locality_id

    def year
      params[:year].to_i
    end

    helper_method :year, :resource_class

    private

    def check_access
      permission_denied unless can_view_census_summary?(year)
    end

    def resource_class
      CensusYears.class_for(year)
    end
  end
end
