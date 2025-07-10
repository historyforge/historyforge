class CivilWarColumnLength < ActiveRecord::Migration[7.2]
  def change
    change_column :census_1910_records, :civil_war_vet, :string, limit: 10
  end
end
