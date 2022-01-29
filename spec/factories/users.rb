# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    login { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'b1g_sekrit' }
    enabled { false }

    trait :active do
      enabled { true }
    end

    trait :with_census_taker_role do
      after(:create) do |user|
        user.add_role Role.find_by(name: 'census taker')
      end
    end

    trait :with_builder_role do
      after(:create) do |user|
        user.add_role Role.find_by(name: 'builder')
      end
    end

    trait :with_administrator_role do
      after(:create) do |user|
        user.add_role Role.find_by(name: 'administrator')
      end
    end

    factory :active_user, traits: [:active]
    factory :builder, traits: %i[active with_builder_role]
    factory :census_taker, traits: %i[active with_census_taker_role]
    factory :administrator, traits: %i[active with_administrator_role]
  end
end
