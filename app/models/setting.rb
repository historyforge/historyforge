class Setting < ApplicationRecord
  def self.value_of(key)
    return unless table_exists?

    setting = find_by(key: key)
    setting&.cast_value
  end

  def cast_value
    return nil if value.blank?

    if input_type == 'string'
      value
    elsif input_type == 'integer'
      value.to_i
    elsif input_type == 'number'
      value.to_f
    elsif input_type == 'boolean'
      value == '1'
    end
  end

  def self.add(key, type: 'string', value:, name: nil, group: 'General', hint: nil)
    setting = find_or_initialize_by key: key
    return if setting.persisted?

    setting.name = name || key.to_s.humanize.titleize
    setting.input_type = type
    setting.value = value.to_s
    setting.group = group
    setting.hint = hint
    setting.save
  end

  def self.can_add_buildings?(year)
    value_of "add_buildings_#{year}"
  end

  def self.can_view_public?(year)
    value_of "enabled_public_#{year}"
  end

  def self.can_view_private?(year)
    value_of "enabled_private_#{year}"
  end

  def self.can_people_public?
    value_of 'people_public'
  end

  def self.can_people_private?
    value_of 'people_private'
  end
end
