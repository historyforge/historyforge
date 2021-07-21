class AddCaptionToPhotographs < ActiveRecord::Migration[6.0]
  def change
    add_column :photographs, :caption, :text
  end
end
