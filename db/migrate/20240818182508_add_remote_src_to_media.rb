class AddRemoteSrcToMedia < ActiveRecord::Migration[7.0]
  def change
    add_column :audios, :remote_url, :string
    add_column :videos, :remote_url, :string
  end
end
