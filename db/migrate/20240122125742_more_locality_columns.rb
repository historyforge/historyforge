class MoreLocalityColumns < ActiveRecord::Migration[7.0]
  def change
    change_table :localities do |t|
      t.string :short_name
      t.boolean :primary, default: false
    end

    reversible do |dir|
      dir.up do
        Locality.find_each do |row|
          row.short_name = row.name
          row.save
        end
        Locality.first.update(primary: true)
      end
    end
  end
end
