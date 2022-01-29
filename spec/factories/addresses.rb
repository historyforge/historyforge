# frozen_string_literal: true

FactoryBot.define do
  factory(:address) do
    is_primary { true }
    house_number { rand(500) }
    name { Faker::Name.name }
    prefix { ([nil] + %w[N E W S])[rand(0..4)] }
    suffix { ([nil] + %w[St Pl Rd Blvd Ave])[rand(0..5)] }
    city { 'Ithaca' }
  end
end
