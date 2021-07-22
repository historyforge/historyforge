FactoryBot.define do
  factory(:building) do
    addresses { build(:address) }
    name { "The #{Faker::Name.name} Building" }
    city { 'Ithaca' }
    state { 'New York' }
    lat { 42 }
    lon { -74 }
  end
end
