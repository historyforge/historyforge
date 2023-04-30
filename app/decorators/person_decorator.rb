# frozen_string_literal: true

class PersonDecorator < ApplicationDecorator
  include DecoratorFormatting

  def reviewed?
    true
  end
end
