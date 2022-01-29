# frozen_string_literal: true

class AddAnnotationModel < ActiveRecord::Migration[6.0]
  def change
    create_table :annotations do |t|
      t.text :annotation_text
      t.bigint :map_overlay_id
      t.bigint :building_id
      t.index [:building_id, :map_overlay_id], unique: true
      t.index [:building_id], name: :index_annotations_on_building_id
      t.index [:map_overlay_id], name: :index_annotations_on_map_overlay_id
    end
    rename_column :buildings, :annotations, :annotations_legacy
    add_foreign_key :annotations, :map_overlays, column: :map_overlay_id
    add_foreign_key :annotations, :buildings, column: :building_id
  end
end
