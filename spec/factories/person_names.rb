FactoryBot.define do
  factory :person_name do
    person { nil }
    is_primary { false }
    last_name { Faker::Name.last_name }
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.middle_name }
    name_prefix { nil }
    name_suffix { nil }
  end
end
