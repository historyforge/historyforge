class CreateSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :settings do |t|
      t.string :key
      t.string :name
      t.string :hint
      t.string :input_type
      t.string :group
      t.text :value

      t.timestamps
    end
  end
end
