class AddTrigramIndices < ActiveRecord::Migration[7.0]
  def change
    add_index :census_1850_records, :searchable_name, using: :gist, opclass: {title: :gist_trgm_ops}
    add_index :census_1860_records, :searchable_name, using: :gist, opclass: {title: :gist_trgm_ops}
    add_index :census_1870_records, :searchable_name, using: :gist, opclass: {title: :gist_trgm_ops}
    add_index :census_1880_records, :searchable_name, using: :gist, opclass: {title: :gist_trgm_ops}
    remove_index :person_names, :searchable_name
    add_index :person_names, :searchable_name, using: :gist, opclass: {title: :gist_trgm_ops}
  end
end
