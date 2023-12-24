class AddTrigramIndices < ActiveRecord::Migration[7.0]
  def change
    with_options(using: :gist, opclass: { title: :gist_trgm_ops }) do
      add_index :census_1850_records, :searchable_name
      add_index :census_1860_records, :searchable_name
      add_index :census_1870_records, :searchable_name
      add_index :census_1880_records, :searchable_name
      add_index :person_names, :searchable_name
    end
  end
end
