class ChangeHomeValueToDecimal < ActiveRecord::Migration[6.0]
  def up
    change_column :census_1930_records, :home_value, :decimal
    change_column :census_1940_records, :home_value, :decimal
  end
  def down
    change_column :census_1930_records, :home_value, :integer
    change_column :census_1940_records, :home_value, :integer
  end
end
