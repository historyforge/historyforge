class AddIndexToTable < ActiveRecord::Migration[7.2]
  def change
    add_index(:audios, :searchable_text)
    add_index(:photographs, :searchable_text)
    add_index(:videos, :searchable_text)
  end
end