class AddAnnotationModel < ActiveRecord::Migration[6.0]
  def change
    create_table "annotations" do |t|
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :map_overlay, foreign_key: { to_table: :map_overlays }
      t.references :building, foreign_key: { to_table: :buildings }
      t.text "annotation_text"
    end
    add_reference :map_overlays, :annotations, index: true
    add_reference :buildings, :annotations, index: true
    rename_column :buildings, :annotations, :annotations_legacy

  end
end
