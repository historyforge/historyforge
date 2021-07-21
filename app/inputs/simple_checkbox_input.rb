class SimpleCheckboxInput < SimpleForm::Inputs::BooleanInput

  def nested_boolean_style?
    true
  end

  def unchecked_value
    nil
  end

end

