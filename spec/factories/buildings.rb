FactoryBot.define do
  factory(:building) do
    addresses { [build(:address, is_primary: true)] }
    name { "The #{Faker::Name.name} Building" }
    city { 'Ithaca' }
    state { 'New York' }
    lat { 42.442376 }
    lon { -76.4907835 }
    locality { Locality.find_or_create_by(name: 'Town of There') }
    building_types { [BuildingType.find_by(name: 'residence')] }
    frame_type_id { 1 }
    lining_type_id { 1 }
    architects { [Architect.find_or_create_by(name: 'William Henry Miller')] }
    year_earliest { 1840 }
    year_latest { 1930 }
    stories { 1 }

    trait :reviewed do
      reviewed_at { 1.day.ago }
      # don't care about reviewed_by for now...
    end
  end
end
