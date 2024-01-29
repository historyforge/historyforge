# frozen_string_literal: true

module DecoratorFormatting
  def format_name(last_name:, middle_name: nil, first_name:, name_prefix: nil, name_suffix: nil)
    name = last_name.dup
    name << ' ' << name_suffix if name_suffix.present?
    name << ', '
    name << first_name if first_name.present?
    name << ' ' << middle_name if middle_name.present?
    name << ' ' << name_prefix if name_prefix.present?
    name.strip.sub(/,$/, '')
  end

  def name
    format_name(
      first_name: object.first_name,
      middle_name: object.middle_name,
      last_name: object.last_name,
      name_prefix: object.name_prefix,
      name_suffix: object.name_suffix
    )
  end
end
