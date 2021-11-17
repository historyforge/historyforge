class Annotation < ApplicationRecord
  has_one :map_overlay
  has_one :building
  validates_presence_of :annotation_text

  def annotation
    annotation_text
  end

  # seems clunky
  def annotation_map_layer_name
    map = MapOverlay.find_by_id(map_overlay_id)
    map.year_depicted.to_s + ' - ' + map.name
  end
end