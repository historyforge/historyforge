class ChangeCensusRecordDefaults < ActiveRecord::Migration[6.0]
  def change
    change_column_default :census_1900_records, :county, from: 'Tompkins', to: nil
    change_column_default :census_1910_records, :county, from: 'Tompkins', to: nil
    change_column_default :census_1920_records, :county, from: 'Tompkins', to: nil
    change_column_default :census_1930_records, :county, from: 'Tompkins', to: nil
    change_column_default :census_1940_records, :county, from: 'Tompkins', to: nil

    change_column_default :census_1900_records, :city, from: 'Ithaca', to: nil
    change_column_default :census_1910_records, :city, from: 'Ithaca', to: nil
    change_column_default :census_1920_records, :city, from: 'Ithaca', to: nil
    change_column_default :census_1930_records, :city, from: 'Ithaca', to: nil
    change_column_default :census_1940_records, :city, from: 'Ithaca', to: nil

    change_column_default :census_1900_records, :state, from: 'NY', to: nil
    change_column_default :census_1910_records, :state, from: 'NY', to: nil
    change_column_default :census_1920_records, :state, from: 'NY', to: nil
    change_column_default :census_1930_records, :state, from: 'NY', to: nil
    change_column_default :census_1940_records, :state, from: 'NY', to: nil
  end
end
