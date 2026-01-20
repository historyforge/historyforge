# frozen_string_literal: true

class BooleanInput < SimpleForm::Inputs::BooleanInput
  def input(wrapper_options={})
    if @builder.is_a?(FormViewBuilder)
      value = @builder.object.send(attribute_name)
      value == true ? 'Yes' : 'blank'
    else
      super
    end
  end

  # This just squelches a deprecation warning about this method receiving wrapper_options as an argument
  def inline_label(wrapper_options)
    inline_option = options[:inline_label]

    if inline_option
      label_text_content = inline_option == true ? label_text : html_escape(inline_option)
      # Get the checkbox ID - SimpleForm generates it as object_name_attribute_name
      checkbox_id = input_html_options[:id] || "#{@builder.object_name.to_s.gsub(/[\[\]]/, '_').gsub(/__+/, '_').chomp('_')}_#{attribute_name}"
      # Return a proper label element with 'for' attribute for accessibility
      @builder.template.content_tag(:label, label_text_content, for: checkbox_id, class: 'form-check-label')
    end
  end
end
