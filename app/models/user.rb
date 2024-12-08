# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  login                     :string
#  email                     :string
#  encrypted_password        :string(128)      default(""), not null
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string
#  remember_token_expires_at :datetime
#  confirmation_token        :string
#  confirmed_at              :datetime
#  reset_password_token      :string
#  enabled                   :boolean          default(TRUE)
#  updated_by                :integer
#  description               :text             default("")
#  confirmation_sent_at      :datetime
#  remember_created_at       :datetime
#  sign_in_count             :integer          default(0), not null
#  current_sign_in_at        :datetime
#  last_sign_in_at           :datetime
#  current_sign_in_ip        :string
#  last_sign_in_ip           :string
#  reset_password_sent_at    :datetime
#  provider                  :string
#  uid                       :string
#  invitation_token          :string
#  invitation_created_at     :datetime
#  invitation_sent_at        :datetime
#  invitation_accepted_at    :datetime
#  invitation_limit          :integer
#  invited_by_type           :string
#  invited_by_id             :bigint
#  invitations_count         :integer          default(0)
#  roles_mask                :integer
#  user_group_id             :bigint
#  unconfirmed_email         :string
#
# Indexes
#
#  index_users_on_invitation_token                   (invitation_token) UNIQUE
#  index_users_on_invited_by_id                      (invited_by_id)
#  index_users_on_invited_by_type_and_invited_by_id  (invited_by_type,invited_by_id)
#  index_users_on_user_group_id                      (user_group_id)
#

# frozen_string_literal: true

class User < ApplicationRecord
  devise :invitable, :database_authenticatable,
         :registerable, :confirmable,
         :recoverable, :rememberable, :trackable,
         :validatable, :omniauthable, omniauth_providers: %i[facebook]

  belongs_to :group, class_name: 'UserGroup', foreign_key: :user_group_id, optional: true, inverse_of: :users
  has_many :search_params, dependent: :destroy

  has_many :census1850_records, dependent: :nullify, class_name: 'Census1850Record', inverse_of: :created_by, foreign_key: :created_by_id
  has_many :census1860_records, dependent: :nullify, class_name: 'Census1860Record', inverse_of: :created_by, foreign_key: :created_by_id
  has_many :census1870_records, dependent: :nullify, class_name: 'Census1870Record', inverse_of: :created_by, foreign_key: :created_by_id
  has_many :census1880_records, dependent: :nullify, class_name: 'Census1880Record', inverse_of: :created_by, foreign_key: :created_by_id
  has_many :census1900_records, dependent: :nullify, class_name: 'Census1900Record', inverse_of: :created_by, foreign_key: :created_by_id
  has_many :census1910_records, dependent: :nullify, class_name: 'Census1910Record', inverse_of: :created_by, foreign_key: :created_by_id
  has_many :census1920_records, dependent: :nullify, class_name: 'Census1920Record', inverse_of: :created_by, foreign_key: :created_by_id
  has_many :census1930_records, dependent: :nullify, class_name: 'Census1930Record', inverse_of: :created_by, foreign_key: :created_by_id
  has_many :census1940_records, dependent: :nullify, class_name: 'Census1940Record', inverse_of: :created_by, foreign_key: :created_by_id
  has_many :census1950_records, dependent: :nullify, class_name: 'Census1950Record', inverse_of: :created_by, foreign_key: :created_by_id

  validates :login, presence: true, length: { within: 3..40 }
  validates :login, uniqueness: { scope: :email, case_sensitive: false }

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

  def self.find_by_invitation_token(original_token, only_valid)
    invitation_token = Devise.token_generator.digest(self, :invitation_token, original_token)
    Rails.logger.info invitation_token.inspect
    Rails.logger.info User.last.invitation_token.inspect
    invitable = find_or_initialize_with_error_by(:invitation_token, invitation_token)
    Rails.logger.info invitable.inspect
    invitable.errors.add(:invitation_token, :invalid) if invitable.invitation_token && invitable.persisted? && !invitable.valid_invitation?
    Rails.logger.info invitable.errors.inspect
    invitable unless only_valid && invitable.errors.present?
  end

  def confirmed?
    enabled? || !!confirmed_at
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

  # Called by Devise
  # Method checks to see if the user is enabled (it will therefore not allow a user who is disabled to log in)
  def active_for_authentication?
    super && enabled?
  end

  # This is overridden from Devise so that admin can invite a user without setting a fake password.
  def password_required?
    public_signup? || password.present? || password_confirmation.present?
  end

  def public_signup?
    @public_signup
  end
  attr_writer :public_signup

  def accept_invitation
    super
    self.enabled = true
  end

  def self.from_omniauth(auth)
    user = User.where(email: auth.info.email, provider: auth.provider).first
    user ||= User.create!(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: Devise.friendly_token[0, 20],
      login: [auth.info.email, auth.provider[0]].join('-')
    )
    user
  end
end
