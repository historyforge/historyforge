class PhotographsController < ApplicationController
  include RestoreSearch
  before_action :load_building, except: :review


  def index
    authorize! :read, Photograph
    @search = Photograph.ransack(params[:q])
    @photographs = @search.result.page(params[:page] || 1).per(20)
    @photographs = @photographs.reviewed unless can?(:review, Photograph)
  end

  def new
    @photograph = model_class.new
    authorize! :create, @photograph
    @photograph.physical_type = PhysicalType.still_image
    if @building
      @photograph.buildings << @building
      @photograph.latitude = @building.latitude
      @photograph.longitude = @building.longitude
    end
  end

  def create
    @photograph = model_class.new resource_params
    authorize! :create, @photograph
    @photograph.created_by = current_user
    if @photograph.save
      flash[:notice] = 'The photograph has been uploaded and saved.'
      redirect_to @building ? [@building, @photograph] : @photograph
    else
      flash[:errors] = 'Sorry we could not save the photograph. Please correct the errors and try again.'
      render action: :new
    end
  end

  def show
    @photograph = model_class.find params[:id]
    authorize! :read, @photograph
    @photograph.prepare_for_review
    @photograph = PhotographPresenter.new @photograph, current_user
  end

  def edit
    @photograph = model_class.find params[:id]
    authorize! :update, @photograph
    @photograph.prepare_for_review
  end

  def update
    @photograph = model_class.find params[:id]
    authorize! :update, @photograph
    @photograph.attributes = resource_params
    @photograph.save validate: false
    if @photograph.valid?
      flash[:notice] = 'The photograph has been updated.'
      redirect_to @building ? [@building, @photograph] : @photograph
    else
      flash[:errors] = 'The photograph has been saved, but cannot be marked as reviewed until it has been fully dressed.'
      @photograph.prepare_for_review
      render action: :edit
    end
  end

  def destroy
    @photograph = model_class.find params[:id]
    authorize! :destroy, @photograph
    if @photograph.destroy
      flash[:notice] = 'The photograph has been deleted.'
      redirect_to action: :index
    else
      flash[:errors] = 'Sorry we could not delete the photograph.'
      render action: :show
    end
  end

  def review
    @photograph = Photograph.find params[:id]
    authorize! :review, @photograph
    @photograph.review! current_user
    if @photograph.reviewed?
      flash[:notice] = 'The photograph is marked as reviewed and open to the public.'
    else
      flash[:errors] = 'Unable to mark the photograph as reviewed.'
    end
    redirect_to @photograph
  end

  private

  def load_building
    if params[:building_id]
      @building = Building.find params[:building_id]
      @model_class = @building.photos

      if @building
        params[:q] ||= {}
        params[:q][:buildings_id_eq] = params[:building_id]
      end
    else
      @model_class = Photograph
      if params[:q] && params[:q][:building_id_eq]
        params[:q].delete :buildings_id_eq
        params[:page] = 1
      end
    end
  end

  attr_reader :model_class

  def resource_params
    params
        .require(:photograph)
        .permit :file, :title, :description, :caption,
                :creator, :subject, { building_ids: [], person_ids: [] },
                :latitude, :longitude,
                :date_text, :date_start, :date_end, :date_type,
                :physical_type_id, :physical_format_id,
                :physical_description, :location, :identifier,
                :notes, :rights_statement_id,
                :date_year, :date_month, :date_day,
                :date_year_end,
                :date_month_end,
                :date_day_end

  end
end