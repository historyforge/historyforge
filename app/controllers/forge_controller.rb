# frozen_string_literal: true

class ForgeController < ApplicationController
  def index
    @locality = Locality.find_by(slug: params[:locality]) if params[:locality]
    @layers = MapOverlay.order(:position).where(active: true)
    return unless @locality

    session[:locality] = @locality.id
    @layers = @layers.joins(:localities).where(localities: { id: @locality.id })
  end
end
