# frozen_string_literal: true

class RadioButtonsOtherInput < CollectionRadioButtonsInput

  def input(wrapper_options=nil)
    fields = super
    fields.sub('{{OTHER}}', other_input.html_safe).html_safe
  end

  def with_extra_items(items)
    keys = items.map(&:last)
    items.unshift ['Left blank', nil]
    other_item = ['{{OTHER}}', (keys.include?(value) || value.blank? ? 'other' : value)]
    if options[:other_index]
      items.insert options[:other_index], other_item
    else
      items << other_item
    end
    items << [options[:unknown] || 'Un - Unknown', 'unknown']
    items
  end

  def other_input
    items = options[:collection].first.is_a?(String) ? options[:collection] : options[:collection].map(&:last)
    other_value = value.blank? || items.include?(value) ? nil : value
    other_label = options[:other_label] || 'Other'
    other_type = options[:other_type] || 'text'
    "#{other_label}: <input type=\"#{other_type}\" value=\"#{other_value}\" data-type=\"other-radio-button\">"
  end
end
