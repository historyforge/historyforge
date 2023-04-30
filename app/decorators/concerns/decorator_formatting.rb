# frozen_string_literal: true

module DecoratorFormatting
  def name
    name = object.last_name.dup
    name << ' ' << object.name_suffix if object.name_suffix.present?
    name << ', '
    name << object.first_name
    name << ' ' << object.middle_name if object.middle_name.present?
    name << ' ' << object.name_prefix if object.name_prefix.present?
    name.strip
  end
end
