class ConnectPeopleToLocalities < ActiveRecord::Migration[7.0]
  def change
    create_table :localities_people, id: false do |t|
      t.references :locality, foreign_key: true
      t.references :person, foreign_key: true
      t.index %i[locality_id person_id], unique: true
    end
    
    reversible do |dir|
      dir.up do
        CensusYears.each do |year|
          execute <<~SQL.squish
            INSERT INTO localities_people SELECT locality_id, person_id FROM census_#{year}_records WHERE locality_id IS NOT NULL and person_id IS NOT NULL ON CONFLICT DO NOTHING;
          SQL
        end
      end
    end
  end
end
