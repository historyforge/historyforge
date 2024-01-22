# frozen_string_literal: true

class ForgeController < ApplicationController
  def index
    @locality = Locality.find_by(slug: params[:locality]) if params[:locality]
    @layers = MapOverlay.order(:position).where(active: true)
    return unless @locality

    @layers = @layers.joins(:localities).where(localities: { id: @locality.id })
    params[:s] ||= {}
    params[:s][:locality_id_eq] = @locality.id
    params[:people] ||= {}
    params[:people][:locality_id_eq] = @locality.id
  end
end
