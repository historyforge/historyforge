# frozen_string_literal: true

class PersonDecorator < ApplicationDecorator
  def name
    [last_name_parts, rest_of_name_parts].compact_blank.join(', ').strip
  end

  def last_name_parts
    [last_name, name_suffix].compact_blank.join(' ')
  end

  def rest_of_name_parts
    [first_name, [middle_name, name_prefix].compact_blank.join(', ')].compact_blank.join(' ')
  end

  def reviewed?
    true
  end
end
