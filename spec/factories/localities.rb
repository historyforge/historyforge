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
#  slug                 :string
#  short_name           :string
#  primary              :boolean          default(FALSE), not null
#
# Indexes
#
#  index_localities_on_slug  (slug) UNIQUE
#

# frozen_string_literal: true

FactoryBot.define do
  factory(:locality) do
    name { Faker::Address.community }
    short_name { name }
  end
end
