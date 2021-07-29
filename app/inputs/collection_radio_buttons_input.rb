# frozen_string_literal: true
class CollectionRadioButtonsInput < SimpleForm::Inputs::CollectionRadioButtonsInput
  def input_type
    :radio_buttons
  end

  def input(wrapper_options={})
    view_input || super
  end

  def view_input
    return unless @builder.is_a?(FormViewBuilder)

    values = @builder.object.public_send(attribute_name)

    return 'blank' if values.blank?

    if value.respond_to?(:map)
      values.map { |v| option_label(v) }.select(&:present?).join("<br>").html_safe
    else
      option_label(value)
    end
  end

  def value
    @value ||= @builder.object.public_send(attribute_name)
  end

  def collection
    return @collection if defined?(@collection)

    options[:collection] = extract_collection_from_choices if !options[:collection] && !options[:original_collection]
    options[:original_collection] ||= options[:collection]
    items = options[:original_collection].dup
    items = items.map { |item| [option_label(item), item]} if items.first&.is_a?(String)
    items = with_extra_items(items) unless options[:bare]
    @collection = items
  end

  def option_label(item)
    return item unless item.kind_of?(String)
    return 'blank' if item.blank?

    if options[:coded]
      code = item.downcase == item ? item.capitalize : item
      code = code.gsub('_', ' ')
      label = translated_option item
      code == label ? label : "#{code} - #{translated_option(item)}"
    else
      translated_option(item).titleize
    end
  end

  def translated_option(item)
    Translator.option(attribute_name, item)
  end

  def with_extra_items(items)
    keys = items.map(&:last)
    keys.include?(nil) ? items : add_blanks(items)
  end

  def add_blanks(items)
    items << [options[:unknown] || "Un - Unknown", 'unknown']
    items.unshift ["Left blank", nil]
    items
  end

  def extract_collection_from_choices
    collection_method_name = attribute_name.to_s.sub(/\_key\Z/, '') << '_choices'
    @builder.object.class.respond_to?(collection_method_name) ? @builder.object.class.send(collection_method_name) : []
  end
end

