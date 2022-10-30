class SearchableName < ActiveRecord::Migration[7.0]
  def change
    rename_table :census1950_records, :census_1950_records
  end
end
