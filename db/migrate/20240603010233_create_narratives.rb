class CreateNarratives < ActiveRecord::Migration[7.0]
  def change
    create_table :narratives do |t|
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.integer :weight, default: 0
      t.string :source
      t.text :notes
      t.integer :date_type
      t.string :date_text
      t.date :date_start
      t.date :date_end

      t.timestamps
    end

    create_table :buildings_narratives, id: false do |t|
      t.references :building, foreign_key: true
      t.references :narrative, foreign_key: true
    end

    create_table :narratives_people, id: false do |t|
      t.references :narrative, foreign_key: true
      t.references :person, foreign_key: true
    end

    add_index :buildings_narratives, [:building_id, :narrative_id], unique: true
    add_index :narratives_people, [:narrative_id, :person_id], unique: true
  end
end
