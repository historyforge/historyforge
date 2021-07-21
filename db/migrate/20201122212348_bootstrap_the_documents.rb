class BootstrapTheDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :document_categories do |t|
      t.string :name
      t.text :description
      t.integer :position

      t.timestamps
    end

    create_table :documents do |t|
      t.references :document_category, foreign_key: true
      t.string :file
      t.string :name
      t.text :description
      t.integer :position
      t.timestamps null: false
    end
  end
end
