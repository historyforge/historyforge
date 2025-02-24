class CreatePlats < ActiveRecord::Migration[7.2]
  def change
    create_table :plats do |t|
      t.integer :parcelid
      t.integer :sheet
      t.integer :row
      t.integer :block
      t.integer :book
      t.integer :page
      t.string :grantor
      t.string :grantee
      t.string :instrument
      t.string :subdivision
      t.boolean :dl
      t.string :document_link
      t.string :contact_link
      t.integer :lots, array: true, default: []
      t.date :date
      t.timestamps
    end
  end
end
