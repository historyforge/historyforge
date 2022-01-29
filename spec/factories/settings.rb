# frozen_string_literal: true

FactoryBot.define do
  factory :setting do
    key { 'facebook_login_enabled' }
    name { 'Enable Facebook Authentication' }
    hint { 'Allow users to signup with their Facebook account.' }
    input_type { 'boolean' }
    group { 'API Keys' }
  end
end
