# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  login                     :string
#  email                     :string
#  encrypted_password        :string(128)      default(""), not null
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string
#  remember_token_expires_at :datetime
#  confirmation_token        :string
#  confirmed_at              :datetime
#  reset_password_token      :string
#  enabled                   :boolean          default(TRUE)
#  updated_by                :integer
#  description               :text             default("")
#  confirmation_sent_at      :datetime
#  remember_created_at       :datetime
#  sign_in_count             :integer          default(0), not null
#  current_sign_in_at        :datetime
#  last_sign_in_at           :datetime
#  current_sign_in_ip        :string
#  last_sign_in_ip           :string
#  reset_password_sent_at    :datetime
#  provider                  :string
#  uid                       :string
#  invitation_token          :string
#  invitation_created_at     :datetime
#  invitation_sent_at        :datetime
#  invitation_accepted_at    :datetime
#  invitation_limit          :integer
#  invited_by_type           :string
#  invited_by_id             :bigint
#  invitations_count         :integer          default(0)
#  roles_mask                :integer
#  user_group_id             :bigint
#
# Indexes
#
#  index_users_on_invitation_token                   (invitation_token) UNIQUE
#  index_users_on_invited_by_id                      (invited_by_id)
#  index_users_on_invited_by_type_and_invited_by_id  (invited_by_type,invited_by_id)
#  index_users_on_user_group_id                      (user_group_id)
#

# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    login { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'b1g_sekrit' }
    enabled { false }
    confirmed_at { 3.days.ago }

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
