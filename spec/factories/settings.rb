# == Schema Information
#
# Table name: settings
#
#  id                :bigint           not null, primary key
#  key               :string
#  name              :string
#  hint              :string
#  input_type        :string
#  group             :string
#  value             :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  settings_group_id :bigint
#
# Indexes
#
#  index_settings_on_settings_group_id  (settings_group_id)
#

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
