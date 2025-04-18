class AddSearchableTextToDocuments < ActiveRecord::Migration[7.2]
  def change
    add_column :documents, :searchable_text, :string
  end
end
