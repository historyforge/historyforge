# frozen_string_literal: true

class UserRolesMask < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :roles_mask, :integer
    reversible do |dir|
      dir.up do
        role_ids = Role.all.map(&:id)
        roles = Role.all.each_with_object({}) { |type, obj| obj[type.name] = type.id }
        old_roles = ActiveRecord::Base.connection
                                      .execute('select id, name from roles')
                                      .to_a
                                      .each_with_object({}) { |type, obj| obj[type['id']] = type['name'].titleize }
        User.find_each do |row|
          sql = "SELECT role_id FROM permissions WHERE user_id=#{row.id}"
          names = ActiveRecord::Base.connection.execute(sql).map { |item| old_roles[item['role_id']] }
          ids = names.map { |name| roles[name] }
          row.update_column :roles_mask, (role_ids & ids).map { |id| 2**id }.sum
        end
      end
    end
  end
end
