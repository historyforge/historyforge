# frozen_string_literal: true

class StreetConversionsController < ApplicationController
  before_action :check_administrator_role

  def index
    @street_conversions = StreetConversion.all
  end

  # def show
  #   @street_conversion = StreetConversion.find params[:id]
  # end

  def new
    @street_conversion = StreetConversion.new
  end

  def create
    @street_conversion = StreetConversion.new resource_params
    if @street_conversion.save
      flash[:notice] = 'Added the new street conversion.'
      redirect_to action: :index
    else
      flash[:error] = "Sorry couldn't do it."
      render action: :new
    end
  end

  def edit
    @street_conversion = StreetConversion.find params[:id]
  end

  def update
    @street_conversion = StreetConversion.find params[:id]
    if @street_conversion.update resource_params
      flash[:notice] = 'Updated the street conversion.'
      redirect_to action: :index
    else
      flash[:error] = "Sorry couldn't do it."
      render action: :edit
    end
  end

  def destroy
    @street_conversion = StreetConversion.find params[:id]
    if @street_conversion.destroy
      flash[:notice] = 'Deleted the street conversion.'
      redirect_to action: :index
    else
      flash[:error] = "Sorry couldn't do it."
      redirect_back fallback_location: { action: :index }
    end
  end

  private

  def resource_params
    params.require(:street_conversion).permit!
  end
end
