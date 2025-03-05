# frozen_string_literal: true

module Buildings
  class MainController < ApplicationController
    include AdvancedRestoreSearch
    include RenderCsv

    wrap_parameters format: []
    respond_to :json, only: %i[index show update]
    respond_to :csv, only: :index
    respond_to :html

    skip_before_action :verify_authenticity_token, only: :autocomplete
    before_action :load_building, only: %i[address show edit update destroy review]
    before_action :authorize_action
    before_action :load_buildings, only: %i[index bulk_review]
    before_action :review_building, only: %i[update review]
    before_action :load_residents, only: :show

    def index
      respond_to do |format|
        format.html
        format.csv { render_csv('buildings', Building) }
        format.json do
          if params[:from]
            @search.expanded = true
            render json: BuildingGridTranslator.new(@search).row_data
          else
            render plain: ForgeQuery.new(@search).to_json, content_type: 'application/json'
          end
        end
      end
    end

    def address
      render json: { id: @building.id, address: @building.primary_street_address }
    end

    def autocomplete
      @buildings = Building.joins(:addresses).ransack(street_address_cont: params[:term]).result.limit(5).by_street_address
      render json: @buildings.map { |building|
        {
          id: building.id,
          name: building.name,
          address: building.full_street_address,
          lat: building.lat,
          lon: building.lon
        }
      }
    end

    def show
      @building = @building.decorate
      respond_to do |format|
        format.html
        format.json { render json: BuildingSerializer.new(@building) }
      end
    end

    def new
      @building = Building.new
      @building.ensure_primary_address
    end

    def edit; end

    def create
      @building = Buildings::Create.run(building_params, current_user)
      if @building.persisted?
        flash[:notice] = 'Building created.'
        redirect_to @building
      else
        flash[:error] = 'Building not saved.'
        @building.ensure_primary_address
        render action: :new
      end
    end

    def update
      saved = Buildings::Update.run(@building, building_params)
      if saved
        @building = @building.decorate
        flash[:notice] = 'Building updated.'
        respond_to do |format|
          format.json { render json: BuildingSerializer.new(@building) }
          format.html { redirect_to action: :show }
        end
      else
        flash[:error] = 'Building not saved.'
        render action: :edit
      end
    end

    def destroy
      if @building.destroy
        flash[:notice] = 'Building deleted.'
        redirect_to action: :index
      else
        flash[:error] = 'Unable to delete building.'
        redirect_to :back
      end
    end

    def review
      if @building.reviewed?
        flash[:notice] = 'Building reviewed.'
        redirect_to @building
      else
        flash[:error] = 'Building not reviewed.'
        render action: :new
      end
    end

    def bulk_review
      @search.scoped.to_a.each do |record|
        next if record.reviewed?

        record.review! current_user
      end

      flash[:notice] = 'The census records are marked as reviewed and available for public view.'
      redirect_back fallback_location: { action: :index }
    end

    def photo
      @photo = Photograph.find params[:id]
      redirect_to @photo.file.variant(resize_to_fit: ResizeToFit.run!(style: params[:style], device: params[:device]))
    end

    private

    def load_residents
      @building.residents = Buildings::FindResidents.run!(
        building: @building,
        year: params[:people],
        filters: params[:peopleParams],
        reviewed_only: !user_signed_in?
      )
    end

    AUTH_ACTIONS = {
      new: :create,
      create: :create,
      edit: :update,
      update: :update,
      destroy: :destroy,
      review: :review,
      bulk_review: :review
    }.freeze

    def load_building
      @building = Building.find params[:id]
    end

    def authorize_action
      authorize! action_to_authorize || :read, @building || Building
    end

    def action_to_authorize
      AUTH_ACTIONS[params[:action].intern]
    end

    def review_building
      @building.review!(current_user) if wants_to_review_building?
    end

    def wants_to_review_building?
      params[:action] == 'review' || (params[:Review] && can?(:review, @building) && !@building.reviewed?)
    end

    def building_params
      params.require(:building).permit(
        :name, :description, :stories, :block_number,
        :year_earliest, :year_latest, :year_latest_circa, :year_earliest_circa,
        :lining_type_id, :frame_type_id, :locality_id, :lat, :lon, :architects_list,
        :investigate, :investigate_reason, :notes, :annotations_legacy, :parent_id, :hive_year,
        {
          building_type_ids: [],
          photos_attributes: %i[_destroy id photo year_taken caption],
          addresses_attributes: %i[_destroy id is_primary house_number prefix name suffix city postal_code year],
          annotations_attributes: %i[_destroy id map_overlay_id annotation_text]
        }
      )
    end

    def load_buildings
      authorize! :read, Building
      @search = BuildingSearch.generate params: search_params,
                                        user: current_user
      @search.expanded = true if request.format.csv?
    end

    def search_params
      params.permit!.to_h
    end
  end
end
