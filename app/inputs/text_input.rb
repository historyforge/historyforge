class TextInput < SimpleForm::Inputs::TextInput

  def input(wrapper_options={})
    if @builder.is_a?(FormViewBuilder)
      text = @builder.object.send(attribute_name)
      @builder.content_tag(:div, @builder.format_text(text), input_html_options)
    else
      super
    end
  end

end