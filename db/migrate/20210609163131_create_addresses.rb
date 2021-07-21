class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.references :building, null: false, foreign_key: true, index: true
      t.boolean :is_primary, default: false
      t.string :house_number
      t.string :prefix
      t.string :name
      t.string :suffix
      t.string :city
      t.string :postal_code

      t.timestamps
    end
  end
end
