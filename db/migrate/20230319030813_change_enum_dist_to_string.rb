class ChangeEnumDistToString < ActiveRecord::Migration[7.0]
  def up
    change_column :census_1880_records, :enum_dist, :string, null: false
    change_column :census_1900_records, :enum_dist, :string, null: false
    change_column :census_1910_records, :enum_dist, :string, null: false
    change_column :census_1920_records, :enum_dist, :string, null: false
    change_column :census_1930_records, :enum_dist, :string, null: false
    change_column :census_1940_records, :enum_dist, :string, null: false
    change_column :census_1950_records, :enum_dist, :string, null: false
  end

  def down
    change_column :census_1880_records, :enum_dist, :integer, null: false
    change_column :census_1900_records, :enum_dist, :integer, null: false
    change_column :census_1910_records, :enum_dist, :integer, null: false
    change_column :census_1920_records, :enum_dist, :integer, null: false
    change_column :census_1930_records, :enum_dist, :integer, null: false
    change_column :census_1940_records, :enum_dist, :integer, null: false
    change_column :census_1950_records, :enum_dist, :integer, null: false
  end
end
