# frozen_string_literal: true

module DecoratorFormatting
  def format_name(last_name:, first_name:, middle_name: nil, name_prefix: nil, name_suffix: nil)
    name = [[last_name, name_suffix].compact_blank.join(' ')]
    name << [first_name, middle_name, name_prefix].compact_blank.join(' ')
    name.join(', ').strip.sub(/,$/, '').presence || 'Name missing'
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
