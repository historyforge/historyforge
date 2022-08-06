# frozen_string_literal: true

class NumericInput < SimpleForm::Inputs::NumericInput
  def input(wrapper_options = nil)
    if @builder.is_a?(FormViewBuilder)
      value = @builder.object.send(attribute_name)
      html = value.to_s
      if value.blank?
        html = if @builder.object.year == 1950 && @builder.object.birth_month.present?
          "Under 1"
        else
          'blank'
        end
      end
      content_tag :div, html, input_html_options
    else
      super
    end
  end
end
