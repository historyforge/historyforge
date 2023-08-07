class RemoveEnumDistFromBelow1880 < ActiveRecord::Migration[7.0]
  def change
    remove_column :census_1850_records, :enum_dist
    remove_column :census_1860_records, :enum_dist
    remove_column :census_1870_records, :enum_dist
  end
end
