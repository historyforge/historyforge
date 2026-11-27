# frozen_string_literal: true

module CensusSummaries
  class Report
    class InvalidSelection < StandardError; end

    attr_reader :year, :search, :search_params, :field, :localities, :locality_selection,
                :coverage_targets, :coverage_counts, :statistics

    def initialize(year:, params:, user:, creator_scope:)
      @year = year
      @user = user
      @creator_scope = creator_scope
      @locality_param = params[:summary_locality]
      @search_params = params.slice('s', 'scope', 'locality_slug')
      @search_params.delete(:scope) unless %w[unhoused unreviewed unmatched].include?(@search_params[:scope])
      @search = build_search
      @site_localities = Locality.all.to_a
      normalize_filters
      @search = build_search if @locality_param.present?
      @field = params[:facet].presence
      @field = 'age' if @field == 'age_months' && age_months_available?
      if @field
        raise InvalidSelection unless search.facets.map(&:to_s).include?(@field)

        @statistics = CensusFacet.new(search, @field).calculate
      end
      load_summary_coverage
    end

    def title
      title = "#{year} Census Record Summaries"
      locality_id ? "#{title} for #{localities.first.name}" : title
    end

    def locality_id
      locality_selection if locality_selection.is_a?(Integer)
    end

    def matching_record_columns
      fields = (search.columns + Array(field)).uniq
      fields |= ['age_months'] if field == 'age' && age_months_available?
      fields
    end

    def link_params
      path_params = search_params.merge(year:, facet: field)
      if search.s[:locality_id_in].blank? && Current.locality
        path_params[:s] = search_params.fetch(:s, {}).merge(locality_id_in: [Current.locality.id])
      elsif search.s[:locality_id_in].blank?
        path_params[:summary_locality] = 'all'
      end
      path_params
    end

    def locality_return_params
      search_params.except(:locality_slug).merge(
        year:, facet: field, s: search_params.fetch(:s, {}).except('locality_id_in').presence
      )
    end

    def review_status
      return 'Reviewed records only' unless @user
      return 'Unreviewed records only' if search.unreviewed?

      'Reviewed and unreviewed records'
    end

    private

    def build_search
      CensusRecordSearch.generate(params: search_params, year:, user: @user, creator_scope: @creator_scope)
    end

    def age_months_available?
      search.entity_class.column_names.include?('age_months')
    end

    def normalize_filters
      filters = search.s.compact_blank
      if filters[:creation_date_range] == 'all'
        filters = filters.except(:creation_date_range, :creation_date_from, :creation_date_to)
      end
      if @locality_param.present?
        ids = @site_localities.map { |locality| locality.id.to_s }
        raise InvalidSelection unless @locality_param == 'all' || ids.include?(@locality_param)

        filters[:locality_id_in] = @locality_param == 'all' ? ids : [@locality_param]
      end
      search_params[:s] = filters.presence
      search_params.compact!
    end

    def load_summary_coverage
      locality_ids = search.s[:locality_id_in]
      @localities = if locality_ids
        selected_ids = Array(locality_ids).map(&:to_s)
        @site_localities.select { |locality| selected_ids.include?(locality.id.to_s) }
      elsif Current.locality
        [Current.locality]
      else
        @site_localities
      end
      @locality_selection = if @localities.one? && (locality_ids || Current.locality) && @locality_param != 'all'
        @localities.first.id
      elsif @localities.size == @site_localities.size
        'all'
      end
      @coverage_targets = CensusCoverage.where(census_year: year, locality: @localities).index_by(&:locality_id)
      @coverage_counts = search.entity_class.where(locality_id: @coverage_targets.keys).group(:locality_id)
                                      .pluck(:locality_id, Arel.sql('COUNT(*)'), Arel.sql('COUNT(reviewed_at)'))
                                      .to_h { |id, total, reviewed| [id, [total, reviewed]] }
    end
  end
end
