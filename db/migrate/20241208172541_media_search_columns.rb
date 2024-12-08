class MediaSearchColumns < ActiveRecord::Migration[7.2]
  def change
    add_column :photographs, :searchable_text, :text
    add_column :narratives, :searchable_text, :text
    add_column :videos, :searchable_text, :text
    add_column :audios, :searchable_text, :text

    up_only do
      preload = { people: :names, buildings: :addresses }
      Photograph.preload(**preload).find_each(&:save)
      Narrative.preload(:rich_text_story, :rich_text_sources, **preload).find_each(&:save)
      Video.preload(**preload).find_each(&:save)
      Audio.preload(**preload).find_each(&:save)
    end
  end
end
