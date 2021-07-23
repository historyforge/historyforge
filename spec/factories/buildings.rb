FactoryBot.define do
  factory(:building) do
    addresses { build(:address) }
    name { "The #{Faker::Name.name} Building" }
    city { 'Ithaca' }
    state { 'New York' }
    lat { 42 }
    lon { -74 }

    trait :reviewed do
      reviewed_at { 1.day.ago }
      # don't care about reviewed_by for now...
    end
  end
end
