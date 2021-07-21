class Buildings::MainController < ApplicationController
  include AdvancedRestoreSearch
  include RenderCsv

  wrap_parameters format: []
  respond_to :json, only: %i[index show update]
  respond_to :csv, only: :index
  respond_to :html

  skip_before_action :verify_authenticity_token, only: :autocomplete

  def index
    @page_title = 'Buildings'
    load_buildings
    render_buildings
  end

  def autocomplete
    @buildings = Building.ransack(street_address_cont: params[:term]).result.limit(5).by_street_address
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

  def new
    authorize! :create, Building
    @building = Building.new
    @building.ensure_primary_address
  end

  def create
    @building = Building.new building_params
    authorize! :create, @building
    @building.created_by = current_user
    if @building.save
      flash[:notice] = 'Building created.'
      redirect_to @building
    else
      flash[:errors] = 'Building not saved.'
      @building.ensure_primary_address
      render action: :new
    end
  end

  def show
    @building = Building.includes(:architects, :building_types).find params[:id]
    authorize! :read, @building
    @building.with_filtered_residents params[:people], params[:peopleParams]
    respond_to do |format|
      format.html do
        @neighbors = @building.neighbors.map { |building| BuildingListingSerializer.new(building) }
        @layer = MapOverlay.where(active: true, year_depicted: 1910).first
      end
      format.json do
        serializer = BuildingSerializer.new(@building)
        render json: serializer
      end
    end
  end

  def edit
    @building = Building.find params[:id]
    @building.photos.build
    authorize! :update, @building
  end

  def update
    @building = Building.find params[:id]
    authorize! :update, @building
    if params[:Review] && can?(:review, @building) && !@building.reviewed?
      @building.reviewed_by = current_user
      @building.reviewed_at = Time.now
    end

    if @building.update(building_params)
      flash[:notice] = 'Building updated.'
      if request.format.json?
        render json: BuildingSerializer.new(@building)
      else
        redirect_to action: :show
      end
    else
      flash[:errors] = 'Building not saved.'
      render action: :edit
    end
  end

  def destroy
    @building = Building.find params[:id]
    authorize! :destroy, @building
    if @building.destroy
      flash[:notice] = 'Building deleted.'
      redirect_to action: :index
    else
      flash[:errors] = 'Unable to delete building.'
      redirect_to :back
    end
  end

  def review
    @building = Building.find params[:id]
    authorize! :review, @building
    @building.investigate = false
    @building.review! current_user
    if @building.reviewed?
      flash[:notice] = 'Building reviewed.'
      redirect_to @building
    else
      flash[:errors] = 'Building not reviewed.'
      render action: :new
    end
  end

  def bulk_review
    authorize! :review, Building
    load_buildings
    @search.scoped.to_a.each do |record|
      next if record.reviewed?

      record.investigate = false
      record.review! current_user
    end

    flash[:notice] = 'The census records are marked as reviewed and available for public view.'
    redirect_back fallback_location: { action: :index }
  end

  def photo
    @photo = Photograph.find params[:id]

    # from style, how wide should it be? as % of 1278px
    width = case params[:device]
            when 'tablet'  then 1024
            when 'phone'   then 740
            else 1278
            end

    if params[:style] != 'full'
      width = case params[:style]
              when 'half'
                (width.to_f * 0.50).ceil
              when 'third'
                (width.to_f * 0.33).ceil
              when 'quarter'
                (width.to_f * 0.25).ceil
              else
                (width.to_f * (params[:style].to_f / 100)).ceil
              end
    end

    redirect_to @photo.file.variant(resize_to_fit: [width, width * 3])
  end

  def new_resource_path
    new_building_path
  end
  helper_method :new_resource_path

  private

  def building_params
    params.require(:building).permit :name, :description, :annotations, :stories, :block_number,
                                     :year_earliest, :year_latest, :year_latest_circa, :year_earliest_circa,
                                     :lining_type_id, :frame_type_id,
                                     :lat, :lon, :city, :state, :postal_code, :architects_list,
                                     :investigate, :investigate_reason, :notes,
                                     { building_type_ids: [],
                                       photos_attributes: %i[_destroy id photo year_taken caption],
                                       addresses_attributes: %i[_destroy id is_primary house_number prefix name suffix city postal_code] }
  end

  def load_buildings
    authorize! :read, Building
    massage_params
    @search = BuildingSearch.generate params: params,
                                      user: current_user,
                                      paged: request.format.html?,
                                      per: 50
  end

  def render_buildings
    if request.format.html?
      render action: :index
    elsif request.format.csv?
      render_csv
    else
      if request.format.json? && !params[:from]
        @search.expanded = true
        @buildings = @search.as_json
      end

      if params[:from]
        @buildings = @search.to_a.map {|building| BuildingPresenter.new(building, current_user) }
        render json: @search.row_data(@buildings)
      else
        respond_with @buildings, each_serializer: BuildingListingSerializer
      end
    end
  end

  def massage_params
    unless params[:q]
      params[:q] = {}
      params.each_pair do |key, value|
        params[:q][key] = value unless %w{controller action page format q}.include?(key)
      end
    end
    if params[:q][:s].blank?
      params[:q][:s] = 'street_address asc'
    end
  end
end
