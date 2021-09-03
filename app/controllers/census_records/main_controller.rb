# frozen_string_literal: true

# Base class for census record CRUD actions.
module CensusRecords
  class MainController < ApplicationController
    include Memery
    before_action :check_access
    before_action :check_demographics_access, only: :demographics

    include AdvancedRestoreSearch
    include RenderCsv

    respond_to :json, only: :index
    respond_to :csv, only: :index
    respond_to :html

    def index
      @page_title = page_title
      load_census_records
      render_census_records
    end

    def new
      authorize! :create, resource_class
      @record = resource_class.new
      @record.set_defaults
      @record.attributes = params.require(:attributes).permit! if params[:attributes]
    end

    # Used to populate the building_id field on census forms
    def building_autocomplete
      record = resource_class.new street_house_number: params[:house],
                                  street_prefix: params[:prefix],
                                  street_name: params[:street],
                                  street_suffix: params[:suffix],
                                  city: params[:city]
      record.auto_strip_attributes
      buildings = BuildingsOnStreet.new(record).perform
      render json: buildings.to_json
    end

    # Any text field that has autocomplete=off is hooked up to autocomplete based on controlled vocabulary and other
    # entries for that field for that year.
    def autocomplete
      results = AttributeAutocomplete.new(
        attribute: params[:attribute],
        term: params[:term],
        year: year
      ).perform
      render json: results
    end

    def demographics
      load_census_records
      @page_title = "Demographics for #{year} US Census"
    end

    def create
      @record = resource_class.new resource_params
      authorize! :create, @record
      @record.created_by = current_user
      if @record.save
        flash[:notice] = 'Census Record saved.'
        after_saved
      else
        flash[:errors] = 'Census Record not saved.'
        render action: :new
      end
    end

    def show
      @model = resource_class.find params[:id]
      authorize! :read, @model
      @record = @model.decorate
    end

    def edit
      @record = resource_class.find params[:id]
      authorize! :update, @record
    end

    def update
      @record = resource_class.find params[:id]
      authorize! :update, @record
      if @record.update(resource_params)
        flash[:notice] = 'Census Record saved.'
        after_saved
      else
        flash[:errors] = 'Census Record not saved.'
        render action: :edit
      end
    end

    def destroy
      @record = resource_class.find params[:id]
      authorize! :destroy, @record
      if @record.destroy
        flash[:notice] = 'Census Record deleted.'
        redirect_to action: :index
      else
        flash[:errors] = 'Unable to delete census record.'
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

    def make_person
      @record = resource_class.find params[:id]
      authorize! :create, resource_class
      @person = @record.generate_person_record
      @person.save
      flash[:notice] = 'A new person record has been created from this census record.'
      redirect_back fallback_location: { action: :index }
    end

    memoize def year
      params[:year].to_i
      # request.fullpath.match(/\d{4}/)[0].to_i
    end
    helper_method :year

    private

    memoize def search_key
      CensusYears.to_words(year)
    end

    # This is a blanket access check for whether this census year is activated for this HF instance
    def check_access
      permission_denied unless can_census?(year)
    end

    def check_demographics_access
      permission_denied unless can_demographics?(year)
    end

    memoize def resource_class
      "Census#{year}Record".safe_constantize
    end
    helper_method :resource_class

    def resource_params
      params[:census_record].each do |key2, value|
        params[:census_record][key2] = nil if %w[on nil].include?(value)
      end
      params.require(:census_record).permit!
    end

    def after_saved
      if params[:then].present?
        attributes = NextCensusRecordAttributes.new(@record, params[:then]).attributes
        redirect_to send("new_census#{year}_record_path", attributes: attributes)
      else
        redirect_to @record
      end
    end

    def load_census_records
      authorize! :read, resource_class
      @search = CensusRecordSearch.generate params: params, year: year, user: current_user
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
        render json: @translator.row_data
      else
        respond_with @search.to_a, each_serializer: CensusRecordSerializer
      end
    end

    memoize def census_record_search_class
      "CensusRecord#{year}Search".safe_constantize
    end

    def page_title
      "#{year} US Census Records"
    end
  end
end
