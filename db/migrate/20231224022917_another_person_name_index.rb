class AnotherPersonNameIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :person_names, %i[person_id is_primary], name: :person_names_primary_name_index
  end
end
