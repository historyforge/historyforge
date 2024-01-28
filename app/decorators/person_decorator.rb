# frozen_string_literal: true

class PersonDecorator < ApplicationDecorator
  include DecoratorFormatting

  def reviewed?
    true
  end

  def locality_ids
    object.localities.map(&:short_name)
  end
end
