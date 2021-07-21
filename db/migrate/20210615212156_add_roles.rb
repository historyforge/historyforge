class AddRoles < ActiveRecord::Migration[6.0]
  def change
    Role.find_or_create_by name: 'reviewer'
  end
end
