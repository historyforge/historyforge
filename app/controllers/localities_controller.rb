# frozen_string_literal: true

class LocalitiesController < ApplicationController
  include Moveable

  before_action :check_administrator_role, except: %i[set reset]

  def set
    locality = Locality.find params[:id]
    locality && (session[:locality] = locality.id)
    redirect_back_or_to root_path
  end

  def reset
    session.delete(:locality)
    redirect_back_or_to root_path
  end

  def index
    @localities = Locality.all
    CensusYears.each do |year|
      ActiveRecord::Precounter.new(@localities).precount(:"census#{year}_records")
    end
  end

  def new
    @locality = Locality.new
  end

  def edit
    @locality = Locality.find params[:id]
  end

  def create
    @locality = Locality.new resource_params
    if @locality.save
      flash[:notice] = 'Added the new locality.'
      redirect_to action: :index
    else
      flash[:errors] = "Sorry couldn't do it."
      render action: :new
    end
  end

  def update
    if resource.update resource_params
      flash[:notice] = 'Updated the locality.'
      redirect_to action: :index
    else
      flash[:errors] = "Sorry couldn't do it."
      render action: :edit
    end
  end

  def destroy
    if resource.destroy
      flash[:notice] = 'Deleted the locality.'
      redirect_to action: :index
    else
      flash[:errors] = "Sorry couldn't do it."
      redirect_back fallback_location: { action: :index }
    end
  end

  private

  def resource_params
    params.require(:locality).permit!
  end

  def locality
    @locality ||= Locality.find(params[:id])
  end

  alias resource locality
end
