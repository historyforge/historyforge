module People
  class CensusRecordsController < ApplicationController
    include AdvancedRestoreSearch
    include RenderCsv

    respond_to :json, only: :index
    respond_to :csv, only: :index
    respond_to :html

    before_action :check_access

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

    def building_autocomplete
      record = resource_class.new
      record.street_house_number = params[:house]
      record.street_prefix = params[:prefix]
      record.street_name = params[:street]
      record.street_suffix = params[:suffix]
      record.city = params[:city]
      record.auto_strip_attributes
      buildings = BuildingsOnStreet.new(record).perform.map { |building| { id: building.id, name: building.name } }
      render json: buildings.to_json
    end

    def autocomplete
      attribute = params[:attribute]
      term = params[:term]
      results = if %w[street_name street_house_number].include?(attribute)
                  building_attribute = if attribute == 'street_name'
                                         'name'
                                       elsif attribute == 'street_house_number'
                                         'house_number'
                                       end
                  Address.ransack(:"#{building_attribute}_start" => term).result.distinct.limit(15).pluck(building_attribute)
                elsif attribute == 'street_address'
                  Address.ransack(street_address_cont: term).result.distinct.limit(15).map(&:address)
                elsif %w[first_name middle_name last_name].include?(attribute)
                  Person.ransack(:"#{attribute}_start" => term).result.distinct.limit(15).pluck(attribute)
                else
                  vocab = Vocabulary.controlled_attribute_for year, attribute
                  if vocab
                    vocab.terms.ransack(name_start: term).result.distinct.limit(15).pluck('name')
                  else
                    resource_class.ransack(:"#{attribute}_start" => term).result.distinct.limit(15).pluck(attribute)
                  end
                end
      render json: results.compact.map(&:strip).uniq
    end

    def create
      @record = resource_class.new resource_params
      authorize! :create, @record
      @record.created_by = current_user
      if @record.save
        flash[:notice] = 'Census Record created.'
        after_saved
      else
        flash[:errors] = 'Census Record not saved.'
        render action: :new
      end
    end

    def show
      @model = resource_class.find params[:id]
      authorize! :read, @model
      @record = CensusRecordPresenter.new @model, current_user
    end

    def edit
      @record = resource_class.find params[:id]
      authorize! :update, @record
    end

    def update
      @record = resource_class.find params[:id]
      authorize! :update, @record
      if @record.update(resource_params)
        flash[:notice] = 'Census Record updated.'
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

    private

    def check_access
      permission_denied unless can_census?(year)
    end

    def page_title
      raise 'Need to implement page title.'
    end

    def resource_class
      raise 'resource_class needs a constant name!'
    end

    def resource_params
      params[:census_record].each do |key2, value|
        params[:census_record][key2] = nil if value == 'on' || value == 'nil'
      end
      params.require(:census_record).permit!
    end

    AFTER_SAVED_FIELDS = {
      'street' => %w[page_number county city ward enum_dist street_prefix street_suffix street_name locality_id],
      'enumeration' => %w[page_number county city ward enum_dist locality_id],
      'page' => %w[page_number county city ward enum_dist locality_id],
      'dwelling' => %w[page_number county city ward enum_dist dwelling_number street_house_number street_prefix street_suffix street_name building_id locality_id],
      'family' => %w[page_number county city ward enum_dist dwelling_number street_house_number street_prefix street_suffix street_name family_id building_id last_name locality_id]
    }

    def after_saved
      if params[:then].present?
        attrs = []
        attrs += AFTER_SAVED_FIELDS[params[:then]]
        attributes = attrs.inject({}) { |hash, item|
          hash[item] = @record.public_send(item)
          hash
        }
        if @record.line_number == @record.per_page
          attributes[:line_number] = 1
          if @record.page_side == 'A'
            attributes[:page_side] = 'B'
            attributes[:page_number] = @record.page_number
          else
            attributes[:page_side] = 'A'
            attributes[:page_number] = @record.page_number + 1
          end
        else
          attributes[:line_number] = (@record.line_number || 0) + 1
          attributes[:page_side] = @record.page_side
          attributes[:page_number] = @record.page_number
        end

        redirect_to action: :new, attributes: attributes
      else
        redirect_to @record
      end
    end

    def load_census_records
      authorize! :read, resource_class
      @search = census_record_search_class.generate params: params, user: current_user, entity_class: resource_class, paged: request.format.html?, per: 100
    end

    def render_census_records
      if request.format.html?
        render action: :index
      else
        @records = @search.to_a
        if params[:from]
          render json: @search.row_data(@records)
        elsif request.format.csv?
          render_csv
        else
          respond_with @records, each_serializer: CensusRecordSerializer
        end
      end
    end

    # These are all defined in subclass but are declared here because of the helper_method call below
    def census_record_search_class; end

    def resource_path; end

    def new_resource_path; end

    def save_as_resource_path; end

    def edit_resource_path; end

    def reviewed_resource_path; end

    def collection_path; end

    def unhoused_collection_path; end

    def unreviewed_collection_path; end

    helper_method :resource_path,
                  :edit_resource_path,
                  :new_resource_path,
                  :save_as_resource_path,
                  :reviewed_resource_path,
                  :collection_path,
                  :unhoused_collection_path,
                  :unreviewed_collection_path,
                  :resource_class
  end
end
