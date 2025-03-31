class AddBuildingToDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :buildings_documents, id: false do |t|
      t.references :building, foreign_key: true
      t.references :document, foreign_key: true
    end

    create_table :documents_people, id: false do |t|
      t.references :document, foreign_key: true
      t.references :person, foreign_key: true
    end

    add_index :buildings_documents, %i[building_id document_id], unique: true
    add_index :documents_people, %i[document_id person_id], unique: true
  end
end
