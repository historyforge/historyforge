# frozen_string_literal: true

class AddRolesMaskToUserGroups < ActiveRecord::Migration[7.2]
  def change
    add_column :user_groups, :roles_mask, :integer
  end
end
