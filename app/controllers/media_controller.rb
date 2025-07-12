# frozen_string_literal: true

class MediaController < ApplicationController
  include Devise::Controllers::StoreLocation
  include RestoreSearch
  before_action :store_location!, only: :new
  before_action :load_parent, except: :review

  class_attribute :model_class
  class_attribute :model_association

  helper_method :what, :model_class

  def index
    @search = model_class.ransack(params[:q])
    @assets = @search.result
                     .page(params[:page] || 1)
                     .per(20)
                     .includes(buildings: :addresses)
                     .accessible_by(current_ability)
  end

  def show
    @asset = scoped_model.find params[:id]
    authorize! :read, @asset
    @asset = @asset.decorate
  end

  def new
    @asset = scoped_model.new
    authorize! :create, @asset

    if @building
      @asset.buildings << @building
      @asset.latitude = @building.latitude
      @asset.longitude = @building.longitude
    elsif @person
      @asset.people << @person
    end
  end

  def edit
    @asset = scoped_model.find params[:id]
    authorize! :update, @asset
  end

  def create
    
    
    
    @asset = scoped_model.new resource_params
    @asset.created_by = current_user
    authorize! :create, @asset
    if @asset.save
      flash[:notice] = "The #{what} has been uploaded and saved."
      perform_redirect
    else
      flash[:error] = "Sorry we could not save the #{what}. Please correct the errors and try again."
      render action: :edit
    end
    @asset.process
  end

  def update
    @asset = scoped_model.find params[:id]
    authorize! :update, @asset
    @asset.attributes = resource_params
    if @asset.save
      flash[:notice] = "The #{what} has been updated."
      perform_redirect
    else
      flash[:error] = "The #{what} has been saved, but cannot be marked as reviewed until it has been fully dressed."
      render action: :edit
    end
  end

  def destroy
    @asset = scoped_model.find params[:id]
    authorize! :destroy, @asset
    if @asset.destroy
      flash[:notice] = "The #{what} has been deleted."
      redirect_to @building || @person || { action: :index }
    else
      flash[:error] = "Sorry we could not delete the #{what}."
      render action: :show
    end
  end

  def review
    @asset = model_class.find params[:id]
    authorize! :review, @asset
    @asset.review! current_user
    if @asset.reviewed?
      flash[:notice] = "The #{what} is marked as reviewed and open to the public."
    else
      flash[:error] = "Unable to mark the #{what} as reviewed."
    end
    redirect_back_or_to @asset
  end

  private

  def perform_redirect
    if @building
      redirect_to building_path(@building, anchor: "#{@asset.class.name.downcase}_#{@asset.id}")
    elsif @person
      redirect_to person_path(@person, anchor: "#{@asset.class.name.downcase}_#{@asset.id}")
    else
      redirect_to @asset
    end
  end

  def store_location!
    return if user_signed_in?

    store_location_for(:user, request.fullpath)
    flash[:error] = 'Please sign in or create a HistoryForge account first.'
    redirect_to(new_user_session_path)
  end

  def what
    @what ||= model_class.model_name.human
  end

  def load_parent
    if params[:person_id]
      @person = Person.find params[:person_id]
      @scoped_model = @person.public_send(model_association)

      if @person
        params[:q] ||= {}
        params[:q][:people_id_eq] = params[:person_id]
      end
    elsif params[:building_id]
      @building = Building.find params[:building_id]
      @scoped_model = @building.public_send(model_association)

      if @building
        params[:q] ||= {}
        params[:q][:buildings_id_eq] = params[:building_id]
      end
    else
      @scoped_model = model_class
      if params[:q] && params[:q][:building_id_eq]
        params[:q].delete :buildings_id_eq
        params[:page] = 1
      end
    end
  end

  attr_reader :scoped_model

  def resource_params
    params
      .require(model_class.model_name.param_key)
      .permit :file, :description, :caption,
              { building_ids: [], person_ids: [] },
              :latitude, :longitude,
              :date_text, :date_start, :date_end, :date_type,
              :location, :identifier,
              :notes,
              :date_year, :date_month, :date_day,
              :date_year_end,
              :date_month_end,
              :date_day_end,
              :remote_url
  end
end
