class AddSlugsToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :localities, :slug, :string, index: { unique: true }
    reversible do |dir|
      dir.up do
        Locality.find_each(&:save)
      end
    end
  end
end
