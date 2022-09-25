class AddPersonDescription < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :description, :text
  end
end
