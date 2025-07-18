class AddFileChecksum < ActiveRecord::Migration[7.2]
  def change
    add_column :photographs, :file_checksum, :text
    add_column :audios, :file_checksum, :text
    add_column :documents, :file_checksum, :text
  end
end
