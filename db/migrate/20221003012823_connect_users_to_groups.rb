class ConnectUsersToGroups < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.references :user_group, foreign_key: true
    end
  end
end
