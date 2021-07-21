class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_many :permissions, dependent: :destroy
  has_many :roles, through: :permissions

  has_many :search_params, dependent: :destroy

  has_many :census1900_records, dependent: :nullify, foreign_key: :created_by_id
  has_many :census1910_records, dependent: :nullify, foreign_key: :created_by_id
  has_many :census1920_records, dependent: :nullify, foreign_key: :created_by_id
  has_many :census1930_records, dependent: :nullify, foreign_key: :created_by_id
  has_many :census1940_records, dependent: :nullify, foreign_key: :created_by_id

  validates_presence_of    :login
  validates_length_of      :login,    :within => 3..40
  validates_uniqueness_of  :login, :scope => :email, :case_sensitive => false

  alias_attribute :active, :enabled

  def name
    login
  end

  def has_role?(name)
    @roles ||= roles.pluck('name') || []
    @roles.include?(name)
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
