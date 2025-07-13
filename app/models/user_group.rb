# == Schema Information
#
# Table name: user_groups
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  roles_mask :integer
#
class UserGroup < ApplicationRecord
  has_many :users, dependent: :nullify
  validates :name, presence: true

  def has_role?(role)
    name = role.is_a?(String) ? role.titleize : role.name
    role_names.include?(name)
  end

  def role_names
    roles.map(&:name)
  end

  def roles
    Role.from_mask(roles_mask)
  end

  def role_ids
    Role.ids_from_mask(roles_mask)
  end

  def role_ids=(ids)
    # Filter out empty strings and nil values, convert to integers
    clean_ids = Array(ids).reject(&:blank?).map(&:to_i)
    self.roles_mask = Role.mask_from_ids(clean_ids)
  end

  def add_role(role)
    ids = role_ids
    ids += [role.id]
    self.role_ids = ids.uniq
    save
  end

  def remove_role(role)
    ids = role_ids
    ids -= [role.id]
    self.role_ids = ids.uniq
    save
  end
end
