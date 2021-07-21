class DateTimeInput < SimpleForm::Inputs::DateTimeInput

  def input(wrapper_options={})
    if @builder.is_a?(FormViewBuilder)
      text = @builder.object.send(attribute_name)
      text && text.strftime('%m/%d/%Y') || 'None'
    else
      super
    end
  end

end