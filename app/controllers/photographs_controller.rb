class PhotographsController < ApplicationController
  include RestoreSearch
  before_action :load_parent, except: :review

  def index
    authorize! :read, Photograph
    @search = Photograph.ransack(params[:q])
    @photographs = @search.result
                          .page(params[:page] || 1)
                          .per(20)
                          .with_attached_file
                          .includes(buildings: :addresses)
    @photographs = @photographs.reviewed unless can?(:review, Photograph)
  end

  def new
    @photograph = model_class.new
    authorize! :create, @photograph

    return unless @building

    @photograph.buildings << @building
    @photograph.latitude = @building.latitude
    @photograph.longitude = @building.longitude
  end

  def create
    @photograph = model_class.new resource_params
    @photograph.created_by = current_user
    authorize! :create, @photograph
    if @photograph.save
      flash[:notice] = 'The photograph has been uploaded and saved.'
      redirect_to @building ? [@building, @photograph] : @photograph
    else
      flash[:errors] = 'Sorry we could not save the photograph. Please correct the errors and try again.'
      render action: :edit
    end
  end

  def show
    @photograph = model_class.find params[:id]
    authorize! :read, @photograph
    @photograph = @photograph.decorate
  end

  def edit
    @photograph = model_class.find params[:id]
    authorize! :update, @photograph
  end

  def update
    @photograph = model_class.find params[:id]
    authorize! :update, @photograph
    @photograph.attributes = resource_params
    if @photograph.save
      flash[:notice] = 'The photograph has been updated.'
      redirect_to @building ? [@building, @photograph] : @photograph
    else
      flash[:errors] = 'The photograph has been saved, but cannot be marked as reviewed until it has been fully dressed.'
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

  def load_parent
    if params[:person_id]
      @person = Person.find params[:person_id]
      @model_class = @person.photos

      if @person
        params[:q] ||= {}
        params[:q][:people_id_eq] = params[:person_id]
      end
    elsif params[:building_id]
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
        .permit :file, :description, :caption,
                { building_ids: [], person_ids: [] },
                :latitude, :longitude,
                :date_text, :date_start, :date_end, :date_type,
                :location, :identifier,
                :notes,
                :date_year, :date_month, :date_day,
                :date_year_end,
                :date_month_end,
                :date_day_end

  end
end