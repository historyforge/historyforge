# frozen_string_literal: true

class Change1880CensusColumn < ActiveRecord::Migration[6.0]
  def up
    change_column :census1880_records, :sick, :string
    rename_table :census1880_records, :census_1880_records
  end

  def down
    rename_table :census_1880_records, :census1880_records
    change_column :census1880_records, :sick, :boolean
  end
end
