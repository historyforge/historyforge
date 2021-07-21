class AddHistidToCensus1910Records < ActiveRecord::Migration[6.0]
  def change
    add_column :census_1900_records, :histid, :uuid
    add_column :census_1910_records, :histid, :uuid
    add_column :census_1920_records, :histid, :uuid
    add_column :census_1930_records, :histid, :uuid
    add_column :census_1940_records, :histid, :uuid
  end
end
