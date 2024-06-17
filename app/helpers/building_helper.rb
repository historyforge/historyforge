# frozen_string_literal: true

module BuildingHelper
  def mini_forge_buildings
    @building.neighbors.includes(:addresses).limit(5).map { |building| BuildingListingSerializer.new(building) }
  end

  def mini_forge_layers
    MapOverlay.order(:position).where(active: true)
  end
end
