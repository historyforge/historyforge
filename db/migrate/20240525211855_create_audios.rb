class CreateAudios < ActiveRecord::Migration[7.0]
  def change
    create_table :audios do |t|
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.text :description
      t.text :notes
      t.text :caption
      t.string :creator
      t.integer :date_type
      t.string :date_text
      t.date :date_start
      t.date :date_end
      t.string :location
      t.string :identifier
      t.decimal :latitude
      t.decimal :longitude
      t.integer :duration
      t.integer :file_size

      t.datetime :processed_at

      t.timestamps
    end
  end
end
