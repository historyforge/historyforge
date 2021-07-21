class AddCommentToVersions < ActiveRecord::Migration[6.0]
  def change
    change_table :versions do |t|
      t.string :comment
    end
  end
end
