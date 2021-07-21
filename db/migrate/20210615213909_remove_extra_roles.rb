class RemoveExtraRoles < ActiveRecord::Migration[6.0]
  def up
    super_user = Role.find_by(name: 'super user')
    dev_role = Role.find_by(name: 'developer')
    admin_role = Role.find_by(name: 'administrator')
    super_user.users.each do |user|
      user.roles << admin_role unless user.has_role?('administrator')
    end
    dev_role.destroy
    super_user.destroy
  end

  def down
    # nothing to do here
  end
end
