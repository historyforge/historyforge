class RemoveUniqueIndexOn1910People < ActiveRecord::Migration[7.0]
  def change
    remove_index :census_1910_records, :person_id
    add_index :census_1910_records, :person_id
  end
end
