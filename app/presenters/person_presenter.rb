class PersonPresenter < ApplicationPresenter
  def name
    "#{last_name}, #{first_name} #{middle_name}".strip
  end

  def reviewed?
    true
  end
end
