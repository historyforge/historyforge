# frozen_string_literal: true

class RadioButtonsOtherInput < CollectionRadioButtonsInput

  def input(wrapper_options=nil)
    fields = super
    fields.sub('{{OTHER}}') { other_input }.html_safe
  end

  def with_extra_items(items)
    items.unshift ['Left blank', nil]
    other_item = ['{{OTHER}}', other_value || 'other']
    if options[:other_index]
      items.insert options[:other_index], other_item
    else
      items << other_item
    end
    items << [options[:unknown] || 'Un - Unknown', 'unknown']
    items
  end

  def other_input
    other_label = options[:other_label] || 'Other'
    other_type = options[:other_type] || 'text'
    template = @builder.template
    field = template.tag.input(type: other_type, value: other_value, data: { type: 'other-radio-button' },
                               aria: { label: "#{other_label} #{attribute_name.to_s.humanize.downcase} as recorded" })
    template.safe_join(["#{other_label}: ", field])
  end

  private def other_value
    keys = options[:original_collection].map { |item| Array(item).last }
    value.presence unless value == 'unknown' || keys.include?(value)
  end
end
