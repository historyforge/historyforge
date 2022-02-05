class SettingsGroup < ApplicationRecord
  has_many :settings, dependent: :nullify
  validates :name, presence: true
  default_scope -> { order(:name) }
end
