# == Schema Information
#
# Table name: user_groups
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  roles_mask :integer
#

FactoryBot.define do
  factory :user_group do
    name { "MyString" }
    roles_mask { 1 }
  end
end
