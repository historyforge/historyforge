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

class Setting < ApplicationRecord
  belongs_to :group, class_name: 'SettingsGroup', foreign_key: :settings_group_id, inverse_of: :settings
  delegate :name, to: :group, prefix: true
  class_attribute :current

  class << self
    def expire_cache
      Rails.cache.delete('settings')
    end

    def loaded?
      current.present?
    end

    def load
      self.current = Rails.cache.fetch('settings') do
        all.index_by(&:key)
      end
    end

    def unload
      self.current = nil
    end

    def value_of(key)
      return unless table_exists?

      setting = current ? current[key.to_s] : find_by(key: key)
      setting&.cast_value
    end

    def add(key, type: 'string', group: 'General', value:, name: nil, hint: nil)
      setting = find_or_initialize_by key: key
      return if setting.persisted?

      setting.name = name || key.to_s.humanize.titleize
      setting.input_type = type
      setting.value = value.to_s
      setting.group = SettingsGroup.find_or_create_by(name: group)
      setting.hint = hint
      setting.save
      expire_cache
    end

    def can_add_buildings?(year)
      value_of "add_buildings_#{year}"
    end

    def can_view_public?(year)
      value_of "enabled_public_#{year}"
    end

    def can_view_private?(year)
      value_of "enabled_private_#{year}"
    end

    def can_view_public_demographics?(year)
      value_of "demographics_public_#{year}"
    end

    def can_view_private_demographics?(year)
      value_of "demographics_private_#{year}"
    end

    def can_people_public?
      value_of 'people_public'
    end

    def can_people_private?
      value_of 'people_private'
    end
  end

  def cast_value
    case input_type
    when 'integer'
      value.to_i
    when 'number'
      value.to_f
    when 'boolean'
      value == '1'
    else
      value.presence || nil
    end
  end
end
