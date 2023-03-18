class BuildingCityAndState < ActiveRecord::Migration[7.0]
  def change
    change_column_null :buildings, :city, true
    change_column_null :buildings, :state, true
  end
end
