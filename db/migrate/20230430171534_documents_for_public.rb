class DocumentsForPublic < ActiveRecord::Migration[7.0]
  def change
    change_table :documents do |t|
      t.boolean :available_to_public, default: false
    end
  end
end
