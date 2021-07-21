class RadioButtonsOtherInput < CollectionRadioButtonsInput

  def input(wrapper_options=nil)
    fields = super
    fields.sub('{{OTHER}}', other_input.html_safe).html_safe
  end

  def with_extra_items(items)
    keys = items.map(&:last)
    items = add_blanks(items) unless keys.include?(nil)
    items << ['{{OTHER}}', (keys.include?(value) || value.blank? ? 'other' : value)]
    items
  end

  def other_input
    items = options[:collection].first.is_a?(String) ? options[:collection] : options[:collection].map(&:last)
    other_value = value.blank? || items.include?(value) ? nil : value
    other_label = options[:other_label] || 'Other'
    "#{other_label}: <input type=\"text\" value=\"#{other_value}\" data-type=\"other-radio-button\">"
  end
end
