# == Schema Information
#
# Table name: localities
#
#  id                   :bigint           not null, primary key
#  name                 :string
#  latitude             :decimal(, )
#  longitude            :decimal(, )
#  position             :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  year_street_renumber :integer
#

# frozen_string_literal: true

FactoryBot.define do
  factory(:locality) do
    name { Faker::Address.community }
  end
end
