# frozen_string_literal: true

module BuildingHelper
  def readable_nearby_buildings
    @building.neighbors.merge(Building.accessible_by(current_ability)).includes(:addresses).limit(5)
  end

  def mini_forge_buildings
    readable_nearby_buildings.map { |building| BuildingListingSerializer.new(building) }
  end

  def mini_forge_current_building
    building = @building.as_json
    if @building.parent_id && !can?(:read, @building.parent)
      building.fetch('object').merge!('parent_id' => nil, 'hive_year' => nil)
    end
    building
  end

  def mini_forge_layers
    MapOverlay.order(:position).where(active: true)
  end
end
