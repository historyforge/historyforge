class MapOverlaysSupportExternalWms < ActiveRecord::Migration[7.0]
  def change
    change_table :map_overlays do |t|
      t.string :layers_param
    end
  end
end
