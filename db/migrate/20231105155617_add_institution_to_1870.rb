class AddInstitutionTo1870 < ActiveRecord::Migration[7.0]
  def change
    add_column :census_1870_records, :institution, :string
  end
end
