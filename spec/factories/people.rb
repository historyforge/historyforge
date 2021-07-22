FactoryBot.define do
  factory(:person) do
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sex { 'M' }
    race { 'W' }
  end
end
