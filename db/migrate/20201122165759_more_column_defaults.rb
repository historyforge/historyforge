class MoreColumnDefaults < ActiveRecord::Migration[6.0]
  def change
    change_column_default :census_1940_records, :pob, from: 'New York', to: nil
    change_column_default :census_1940_records, :pob_mother, from: 'New York', to: nil
    change_column_default :census_1940_records, :pob_father, from: 'New York', to: nil

    change_column_default :census_1930_records, :pob, from: 'New York', to: nil
    change_column_default :census_1930_records, :pob_mother, from: 'New York', to: nil
    change_column_default :census_1930_records, :pob_father, from: 'New York', to: nil

    change_column_default :census_1920_records, :pob, from: 'New York', to: nil
    change_column_default :census_1920_records, :pob_mother, from: 'New York', to: nil
    change_column_default :census_1920_records, :pob_father, from: 'New York', to: nil

    change_column_default :census_1910_records, :pob, from: 'New York', to: nil
    change_column_default :census_1910_records, :pob_mother, from: 'New York', to: nil
    change_column_default :census_1910_records, :pob_father, from: 'New York', to: nil

    change_column_default :census_1900_records, :pob, from: 'New York', to: nil
    change_column_default :census_1900_records, :pob_mother, from: 'New York', to: nil
    change_column_default :census_1900_records, :pob_father, from: 'New York', to: nil
  end
end
