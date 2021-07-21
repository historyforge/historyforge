class NumericInput < SimpleForm::Inputs::NumericInput
  def input(wrapper_options = nil)
    if @builder.is_a?(FormViewBuilder)
      value = @builder.object.send(attribute_name)
      html = value.to_s
      html = 'blank' if value.blank?
      content_tag :div, html, input_html_options
    else
      super
    end
  end
end