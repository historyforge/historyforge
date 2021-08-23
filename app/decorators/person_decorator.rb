# frozen_string_literal: true

class PersonDecorator < ApplicationDecorator
  def name
    "#{last_name}, #{first_name} #{middle_name}".strip
  end

  def reviewed?
    true
  end
end
