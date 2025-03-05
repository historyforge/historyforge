# frozen_string_literal: true

# Map overlays are the historical map layers that show on top of Google Maps. They are generally maintained
# on a MapWarper installation at maps.historyforge.net. Here we just get their WMS url and some metadata that
# helps us use them in context.
class MapOverlaysController < ApplicationController
  before_action :check_administrator_role

  def index
    @map_overlays = MapOverlay.includes(:localities)
    @map_overlays = @map_overlays.where(localities: { id: Current.locality_id }) if Current.locality_id
  end

  def new
    @map_overlay = MapOverlay.new
  end

  def create
    @map_overlay = MapOverlay.new resource_params
    if @map_overlay.save
      flash[:notice] = 'Added the new map overlay.'
      redirect_to action: :index
    else
      flash[:error] = "Sorry couldn't do it."
      render action: :new
    end
  end

  def edit
    @map_overlay = MapOverlay.find params[:id]
  end

  def update
    @map_overlay = MapOverlay.find params[:id]
    if @map_overlay.update resource_params
      flash[:notice] = 'Updated the map overlay.'
      redirect_to action: :index

    else
      flash[:error] = "Sorry couldn't do it."
      render action: :edit
    end
  end

  def destroy
    @map_overlay = MapOverlay.find params[:id]
    if @map_overlay.destroy
      flash[:notice] = 'Deleted the map overlay.'
      redirect_to action: :index
    elsif @map_overlay.check_for_annotations
      flash[:error] = 'Cannot remove with active annotations'
    else
      flash[:error] = "Sorry couldn't do it."
    end
    redirect_to action: :index
  end

  private

  def resource_params
    params.require(:map_overlay).permit!
  end
end
