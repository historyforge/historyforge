# frozen_string_literal: true

class StandardizeProfessionFieldAsOccupation < ActiveRecord::Migration[6.0]
  def change
    rename_column :census_1900_records, :profession, :occupation
    rename_column :census_1910_records, :profession, :occupation
    rename_column :census_1920_records, :profession, :occupation
    rename_column :census_1930_records, :profession, :occupation
    rename_column :census_1930_records, :profession_code, :occupation_code
    rename_column :census_1940_records, :usual_profession, :usual_occupation
  end
end
