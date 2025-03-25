class AddEverEnslavedToPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :people, :ever_enslaved, :boolean, default: false
  end
end
