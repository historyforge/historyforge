# == Schema Information
#
# Table name: user_groups
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UserGroup < ApplicationRecord
  has_many :users, dependent: :nullify
  validates :name, presence: true
end
