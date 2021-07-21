class BuildingColumnDefaults < ActiveRecord::Migration[6.0]
  def change
    change_column_default :buildings, :city, from: 'Ithaca', to: nil
    change_column_default :buildings, :state, from: 'NY', to: nil
    change_column_default :buildings, :postal_code, from: '14850', to: nil
  end
end
