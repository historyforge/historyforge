# frozen_string_literal: true

task migrate_annotations: :environment do
  layer = MapOverlay.find 21 # insert the id of your default map overlay here
  Building.find_each do |building|
    next if building.annotations_legacy.blank?

    Annotation.find_or_create_by! building_id: building.id,
                                  map_overlay_id: layer.id,
                                  annotation_text: building.annotations_legacy
  end
end
