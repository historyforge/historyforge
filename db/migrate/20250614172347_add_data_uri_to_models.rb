class AddDataUriToModels < ActiveRecord::Migration[7.2]
  def change
    add_column :videos, :data_uri, :text
    add_column :photographs, :data_uri, :text
    add_column :audios, :data_uri, :text
    add_column :documents, :data_uri, :text
  end
end
