class ConnectMediaToPersonsAndBuildings < ActiveRecord::Migration[7.0]
  def change
    create_table :people_videos, id: false do |t|
      t.references :person, foreign_key: true
      t.references :video, foreign_key: true
    end
    add_index :people_videos, %i[person_id video_id]

    create_table :audios_people, id: false do |t|
      t.references :person, foreign_key: true
      t.references :audio, foreign_key: true
    end
    add_index :audios_people, %i[person_id audio_id]

    create_table :buildings_videos, id: false do |t|
      t.references :building, foreign_key: true
      t.references :video, foreign_key: true
    end
    add_index :buildings_videos, %i[building_id video_id]

    create_table :audios_buildings, id: false do |t|
      t.references :audio, foreign_key: true
      t.references :building, foreign_key: true
    end
    add_index :audios_buildings, %i[audio_id building_id]
  end
end
