class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_many :search_params, dependent: :destroy

  CensusYears.each do |year|
    has_many :"census#{year}_records", dependent: :nullify, foreign_key: :created_by_id
  end

  validates_presence_of    :login
  validates_length_of      :login, within: 3..40
  validates_uniqueness_of  :login, scope: :email, case_sensitive: false

  alias_attribute :active, :enabled

  scope :roles_id_eq, lambda { |id|
    if id.blank?
      where('roles_mask > 0')
    else
      where 'roles_mask & ? > 0', Role.mask_for(id)
    end
  }

  def self.ransackable_scopes(_auth_object=nil)
    %i[roles_id_eq]
  end

  def name
    login
  end

  def has_role?(role)
    name = role.is_a?(String) ? role.titleize : role.name
    role_names.include?(name)
  end

  def role_names
    roles.map(&:name)
  end
  memoize :role_names

  def roles
    Role.from_mask(roles_mask)
  end
  memoize :roles

  def role_ids
    Role.ids_from_mask(roles_mask)
  end

  def role_ids=(ids)
    self.roles_mask = Role.mask_from_ids(ids)
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

  #Called by Devise
  #Method checks to see if the user is enabled (it will therefore not allow a user who is disabled to log in)
  def active_for_authentication?
    super && enabled?
  end

  def password_required?
    password.present?
  end

  def accept_invitation
    self.invitation_accepted_at = Time.now.utc
    self.invitation_token = nil
    self.enabled = true
  end
end
