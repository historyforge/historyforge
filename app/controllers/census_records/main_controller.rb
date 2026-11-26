# frozen_string_literal: true

require 'csv'

# Base class for census record CRUD actions.
module CensusRecords
  class MainController < ApplicationController
    include FastMemoize
    include AdvancedRestoreSearch
    include RenderCsv
    include SqlInjectionProtection

    prepend_before_action :check_access, except: :rebuild
    prepend_before_action :check_demographics_access, only: :demographics

    respond_to :json, only: :index
    respond_to :csv, only: :index
    respond_to :html

    def rebuild
      authorize! :manage, :all
      CensusYears.each do |year|
        "Census#{year}Record".constantize.rebuild_pg_search_documents
      end
      flash[:notice] = 'Person index rebuilt.'
      redirect_back_or_to(root_path)
    end

    def index
      @page_title = page_title
      load_census_records
      render_census_records
    end

    def advanced_search_filters; end

    def show
      @model = resource_class.find params[:id]
      authorize! :read, @model
      @record = @model.decorate
      load_navigation
    end

    def new
      authorize! :create, resource_class
      @record = resource_class.new
      @record.set_defaults
      @record.attributes = params.require(:attributes).permit! if params[:attributes]
      @record.locality = Locality.first if Locality.count == 1
    end

    # Used to populate the building_id field on census forms
    def building_autocomplete
      record = resource_class.new street_house_number: params[:house],
                                  street_prefix: params[:prefix],
                                  street_name: params[:street],
                                  street_suffix: params[:suffix],
                                  locality_id: params[:locality_id]
      record.auto_strip_attributes
      buildings = Buildings::PossibleMatches.perform(record)
      render json: buildings.to_json
    end

    # Any text field that has autocomplete=off is hooked up to autocomplete based on controlled vocabulary and other
    # entries for that field for that year.
    def autocomplete
      results = AttributeAutocomplete.new(
        attribute: params[:attribute],
        term: params[:term],
        year:,
      ).perform
      render json: results
    end

    def demographics
      @summary_params = search_params.slice('s', 'scope', 'locality_slug')
      @summary_params.delete(:scope) unless %w[unhoused unreviewed unmatched].include?(@summary_params[:scope])
      load_census_records(params: @summary_params)
      @summary_site_localities = Locality.all.to_a
      filters = @search.s.compact_blank
      if filters[:creation_date_range] == 'all'
        filters = filters.except(:creation_date_range, :creation_date_from, :creation_date_to)
      end
      if params[:summary_locality].present?
        selection = params[:summary_locality]
        ids = @summary_site_localities.map { |locality| locality.id.to_s }
        return head :bad_request unless selection == 'all' || ids.include?(selection)

        filters[:locality_id_in] = selection == 'all' ? ids : [selection]
      end
      @summary_params[:s] = filters.presence
      @summary_params.compact!
      load_census_records(params: @summary_params) if params[:summary_locality].present?
      @page_title = "#{year} Census Record Summaries"
      @facet = params[:facet].presence
      @age_months_available = resource_class.column_names.include?('age_months')
      @facet = 'age' if @facet == 'age_months' && @age_months_available
      if @facet
        return head :bad_request unless @search.facets.map(&:to_s).include?(@facet)

        @summary = CensusFacet.new(@search, @facet).calculate
      end
      load_summary_coverage
      @page_title += " for #{@summary_localities.first.name}" if @summary_locality_value.is_a?(Integer)
      if request.format.csv?
        return head :bad_request unless @summary

        return send_data summary_csv, filename: "historyforge-#{year}-#{@facet}-summary.csv",
                                      type: 'text/csv; charset=utf-8'
      end
      load_summary_years
    end

    def summary_locality_return_path
      return unless action_name == 'demographics'

      demographics_census_records_path(@summary_params.except(:locality_slug).merge(
        year:, facet: @facet, s: @summary_params.fetch(:s, {}).except('locality_id_in').presence
      ))
    end
    helper_method :summary_locality_return_path, :summary_locality_id

    def summary_locality_id
      @summary_locality_value if @summary_locality_value.is_a?(Integer)
    end

    def edit
      @record = resource_class.find params[:id]
      authorize! :update, @record
    end

    def create
      @record = resource_class.new resource_params
      authorize! :create, @record
      @record.created_by = current_user
      if @record.save
        flash[:notice] = 'Census Record saved.'
        after_saved
      else
        render_form_with_errors(:new)
      end
    end

    def update
      @record = resource_class.find params[:id]
      authorize! :update, @record
      if @record.update(resource_params)
        flash[:notice] = 'Census Record saved.'
        after_saved
      else
        render_form_with_errors(:edit)
      end
    end

    def destroy
      @record = resource_class.find params[:id]
      authorize! :destroy, @record
      if @record.destroy
        flash[:notice] = 'Census Record deleted.'
        redirect_to action: :index
      else
        flash[:error] = 'Unable to delete census record.'
        redirect_back fallback_location: { action: :index }
      end
    end

    def save_as
      @record = resource_class.find params[:id]
      authorize! :create, resource_class
      after_saved
    end

    def reviewed
      @record = resource_class.find params[:id]
      authorize! :review, @record
      @record.review! current_user
      flash[:notice] = 'The census record is marked as reviewed and available for public view.'
      redirect_back fallback_location: { action: :index }
    end

    def bulk_review
      authorize! :review, resource_class
      params[:from] = 0
      params[:to] = 100
      load_census_records

      @search.scoped.to_a.each do |record|
        next if record.reviewed?

        record.review! current_user
      end

      flash[:notice] = 'The census records are marked as reviewed and available for public view.'
      redirect_back fallback_location: { action: :index }
    end

    def bulk_person_match
      authorize! :review, resource_class
      params[:from] = 0
      params[:to] = 100
      load_census_records

      count = 0
      @search.scoped.to_a.each do |record|
        next if record.person_id.present?

        person = People::GenerateFromCensusRecord.call(record:)
        count += 1 if person.persisted?
      end

      flash[:notice] = "Person records have been generated for #{count} census records."
      redirect_back fallback_location: { action: :index }
    end

    def make_person
      @record = resource_class.find params[:id]
      authorize! :create, resource_class
      person = People::GenerateFromCensusRecord.call(record: @record)
      if person.persisted?
        flash[:notice] = 'A new person record has been created from this census record.'
      else
        error_message = 'Unable to create a person record from this census record. '
        error_message += person.errors.full_messages.to_sentence if person.errors.any?
        flash[:error] = error_message
      end
      redirect_back fallback_location: { action: :index }
    end

    def year
      params[:year].to_i
    end

    memoize :year
    helper_method :year

    private

    def load_navigation
      navigation_params = grid_navigation_params
      return unless navigation_params

      @navigation = CensusRecordSearch.generate(
        params: navigation_params, year:, user: current_user, creator_scope: creator_search_scope(resource_class)
      ).navigation_neighbors(@model.id)
    end

    def search_key
      CensusYears.to_words(year)
    end

    memoize :search_key

    # This is a blanket access check for whether this census year is activated for this HF instance
    def check_access
      permission_denied unless can_census?(year)
    end

    def check_demographics_access
      permission_denied unless can_demographics?(year)
    end

    def resource_class
      "Census#{year}Record".safe_constantize
    end

    memoize :resource_class
    helper_method :resource_class

    NULLABLES = %w[on nil].freeze

    def resource_params
      params[:census_record].each do |key2, value|
        params[:census_record][key2] = nil if NULLABLES.include?(value)
      end
      params.require(:census_record).permit!
    end

    def after_saved
      if params[:context] && params[:context] == 'person'
        redirect_to @record.person
      elsif params[:then].present?
        attributes = NextCensusRecordAttributes.call(@record, params[:then])
        redirect_to send(:"new_census#{year}_record_path", attributes:)
      else
        redirect_to @record
      end
    end

    def search_params
      params.permit!.to_h
    end

    def load_census_records(params: search_params)
      authorize! :read, resource_class
      @search = CensusRecordSearch.generate(
        params:, year:, user: current_user, creator_scope: creator_search_scope(resource_class)
      )
    end

    def summary_csv
      locality_names = @summary_localities.map(&:name)
      denominator = @summary[:included]
      filters = @summary_params.fetch(:s, {}).except('locality_id_in')
      context = [
        year, @facet, Translator.filter(resource_class, @facet), summary_csv_text(locality_names.to_sentence),
        @summary_params[:scope], summary_review_status,
        filters.to_json, @summary[:matching], denominator, @summary[:blank],
        @summary[:unknown], @summary[:outside_range], @summary[:conditional],
        @summary_localities.count { |locality| @coverage_targets.key?(locality.id) },
        @summary_localities.size
      ]

      CSV.generate do |csv|
        csv << %w[census_year field field_label localities search_scope record_access filters_json
                  matching_records included_records blank_records unknown_records outside_chart_range
                  conditional_field localities_with_coverage_targets locality_count recorded_value records
                  percent_of_included]
        if denominator.zero?
          csv << context
        else
          @summary[:rows].each do |label, count|
            csv << [*context, summary_csv_text(label), count, (count.fdiv(denominator) * 100).round(2)]
          end
        end
      end
    end

    def summary_csv_text(value)
      return value unless value.is_a?(String) && value.match?(/\A(?:[\t\r\n]|[[:space:]]*[=+\-@])/)

      "'#{value}"
    end

    def summary_review_status
      return 'Reviewed records only' unless current_user
      return 'Unreviewed records only' if @search.unreviewed?

      'Reviewed and unreviewed records'
    end
    helper_method :summary_review_status

    def load_summary_coverage
      locality_ids = @search.s[:locality_id_in]
      @summary_localities = if locality_ids
        selected_ids = Array(locality_ids).map(&:to_s)
        @summary_site_localities.select { |locality| selected_ids.include?(locality.id.to_s) }
      elsif Current.locality
        [Current.locality]
      else
        @summary_site_localities
      end
      @summary_locality_value = if @summary_localities.one? && (locality_ids || Current.locality) && params[:summary_locality] != 'all'
        @summary_localities.first.id
      elsif @summary_localities.size == @summary_site_localities.size
        'all'
      end
      @coverage_targets = CensusCoverage.where(census_year: year, locality: @summary_localities).index_by(&:locality_id)
      @coverage_counts = resource_class.where(locality_id: @coverage_targets.keys).group(:locality_id)
                                      .pluck(:locality_id, Arel.sql('COUNT(*)'), Arel.sql('COUNT(reviewed_at)'))
                                      .to_h { |id, total, reviewed| [id, [total, reviewed]] }
    end

    def load_summary_years
      years = CensusYears::YEARS.select { |candidate| can_census?(candidate) && can_demographics?(candidate) }
      @other_summary_years_enabled = years.any? { |candidate| candidate != year }
      @summary_years = years.filter_map do |candidate|
        next [candidate, nil] if candidate == year

        config = "Census#{candidate}FormFields".constantize
        next if @facet && !config.facets.include?(@facet.to_sym)

        [candidate, summary_year_params(candidate, config)]
      end.to_h
    end

    def summary_year_params(candidate, config)
      record_class = CensusYears.class_for(candidate)
      current_filters = @summary_params.fetch(:s, {})
      filters = transferable_summary_filters(config, current_filters)
      if creator_search_scope(record_class)
        filters.merge!(current_filters.slice(*CreatorFilter::PARAM_KEYS))
      end
      @summary_params.except(:s).merge(year: candidate, s: filters.presence, facet: @facet,
                                       omitted_filters: (current_filters.size - filters.size).nonzero?).compact
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

    def render_census_records
      @translator = CensusGridTranslator.new(@search)
      respond_to do |format|
        format.html { render action: :index }
        format.csv { render_csv("census-records-#{year}", resource_class) }
        format.json { render_json }
      end
    end

    def render_json
      if params[:from]
        navigation = grid_navigation_context
        render json: @translator.row_data { |id| census_record_path(year:, id:, navigation:) }
      else
        render json: @search.results.map { |record| CensusRecordSerializer.new(record).serializable_hash }.to_a
      end
    end

    def census_record_search_class
      "CensusRecord#{year}Search".safe_constantize
    end

    memoize :census_record_search_class

    def page_title
      "#{year} US Census Records"
    end
  end
end
