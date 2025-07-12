class AddSearchableTextToAddresses < ActiveRecord::Migration[7.2]
  def change
    add_column :addresses, :searchable_text, :text
  end
end
