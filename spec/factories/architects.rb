# frozen_string_literal: true

FactoryBot.define do
  factory(:architect) do
    name { Faker::Name.name}
  end
end
