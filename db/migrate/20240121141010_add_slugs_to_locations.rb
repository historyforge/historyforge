class AddSlugsToLocations < ActiveRecord::Migration[7.0]
  def change
    change_table :localities do |t|
      t.string :slug, index: { unique: true }
      t.string :short_name
      t.boolean :primary, default: false, null: false
    end
    reversible do |dir|
      dir.up do
        Locality.first.update(primary: true)
        Locality.find_each do |row|
          row.short_name = row.name
          row.save
        end
      end
    end
  end
end
