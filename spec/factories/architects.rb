# == Schema Information
#
# Table name: architects
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

FactoryBot.define do
  factory(:architect) do
    name { Faker::Name.name}
  end
end
