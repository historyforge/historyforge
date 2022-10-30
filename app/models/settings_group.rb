# == Schema Information
#
# Table name: settings_groups
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SettingsGroup < ApplicationRecord
  has_many :settings, dependent: :nullify
  validates :name, presence: true
  default_scope -> { order(:name) }
end
