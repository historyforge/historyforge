class CreateBulkUpdates < ActiveRecord::Migration[6.0]
  def change
    create_table :bulk_updates do |t|
      t.integer :year
      t.string :field
      t.string :value_from
      t.string :value_to
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
