# frozen_string_literal: true

class AttachBuildingsAndMapLayersToLocalities < ActiveRecord::Migration[6.0]
  def change
    change_table :buildings do |t|
      t.references :locality, foreign_key: true
    end
    create_join_table :localities, :map_overlays

    reversible do |dir|
      dir.up do
        Building.find_each do |building|
          building.locality = building.residents&.first&.locality
          building.save
        end
      end
    end
  end
end
