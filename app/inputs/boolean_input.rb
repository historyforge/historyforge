class BooleanInput < SimpleForm::Inputs::BooleanInput
  def input(wrapper_options={})
    if @builder.is_a?(FormViewBuilder)
      value = @builder.object.send(attribute_name)
      value === true ? 'Yes' : 'blank'
      # if value
      #   'Yes'
      #   # self.class.boolean_collection.detect {|item| item[1] == value }.andand[0]
      # end
    else
      super
    end
  end

  # This just squelches a deprecation warning about this method receiving wrapper_options as an argument
  def inline_label(wrapper_options)
    inline_option = options[:inline_label]

    if inline_option
      label = inline_option == true ? label_text : html_escape(inline_option)
      " #{label}".html_safe
    end
  end
end
