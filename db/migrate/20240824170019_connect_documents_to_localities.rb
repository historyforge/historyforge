class ConnectDocumentsToLocalities < ActiveRecord::Migration[7.0]
  def change
    create_table :documents_localities, id: false do |t|
      t.references :document, foreign_key: true
      t.references :locality, foreign_key: true
    end
    add_index :documents_localities, %i[document_id locality_id], unique: true
  end
end
