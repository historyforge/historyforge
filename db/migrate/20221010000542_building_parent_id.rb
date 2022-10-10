class BuildingParentId < ActiveRecord::Migration[7.0]
  def change
    change_table :buildings do |t|
      t.references :parent, foreign_key: { to_table: :buildings }
      t.integer :hive_year
    end
  end
end
