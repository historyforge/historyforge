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

    if value.is_a?(Integer)
      %i[birth_month marriage_month].include?(attribute_name) ? Date::MONTHNAMES[value] : value
    elsif value.respond_to?(:map)
      values.map { |v| option_label(v) }.select(&:present?).join('<br>').html_safe
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
    items = items.map { |item| [option_label(item), item] } if items.first.is_a?(String)
    items = with_extra_items(items) unless options[:bare]
    @collection = items
  end

  def option_label(item)
    if options[:coded]
      code = item.downcase == item ? item.capitalize : item
      code = code.tr('_', ' ')
      if attribute_name == :race && @builder.object.class.respond_to?(:translate_race_code)
        code = @builder.object.class.translate_race_code(code)
      end
      label = translated_option item, code: options[:coded]
      return label if %w[5000+ 10000+ P6].include?(code)
      return 'Blank - White' if code == 'W' && special_race_question?

      code == label ? label : "#{code} - #{label}"
    else
      translated_option(item).titleize
    end
  end

  def translated_option(item, code: false)
    attribute = code.is_a?(Symbol) ? code : attribute_name
    Translator.option(attribute, item)
  end

  def with_extra_items(items)
    keys = items.map(&:last)
    keys.include?(nil) ? items : add_blanks(items)
  end

  def add_blanks(items)
    items << [options[:unknown] || 'Un - Unknown', 'unknown']
    items.unshift ['Left blank', nil] unless special_race_question?
    items
  end

  def extract_collection_from_choices
    collection_method_name = attribute_name.to_s.sub(/\_key\Z/, '') << '_choices'
    @builder.object.class.respond_to?(collection_method_name) ? @builder.object.class.send(collection_method_name) : []
  end

  def special_race_question?
    attribute_name == :race && @builder.object.respond_to?(:year) && [1850, 1860].include?(@builder.object.year)
  end
end
