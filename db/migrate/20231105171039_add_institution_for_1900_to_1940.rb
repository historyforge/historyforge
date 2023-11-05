class AddInstitutionFor1900To1940 < ActiveRecord::Migration[7.0]
  def change
    add_column :census_1880_records, :institution, :string
    add_column :census_1900_records, :institution, :string
    add_column :census_1910_records, :institution, :string
    add_column :census_1920_records, :institution, :string
    add_column :census_1930_records, :institution, :string
    add_column :census_1940_records, :institution, :string
  end
end
