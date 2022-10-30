# == Schema Information
#
# Table name: settings_groups
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :settings_group do
    name { "MyString" }
  end
end
