# frozen_string_literal: true

FactoryBot.define do
  factory(:locality) do
    name { Faker::Address.community }
  end
end
