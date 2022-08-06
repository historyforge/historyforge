class AddNotesToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :notes, :text
  end
end
