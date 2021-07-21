class ChangeBuildingsPostalCodeNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :buildings, :postal_code, true
  end
end
