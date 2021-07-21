class StringInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options={})
    if @builder.is_a?(FormViewBuilder)
      text = @builder.object.send(attribute_name)
      text = 'blank' if text.blank?
      @builder.content_tag(:div, text, input_html_options)
    else
      super
    end
  end
end
