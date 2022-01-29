class RemoveExtraneousForeignKeysPriorToTableRemoval < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key 'buildings', 'building_types'
    remove_foreign_key 'buildings_building_types', 'building_types'
    remove_foreign_key 'buildings_building_types', 'buildings'
  end
end
