# frozen_string_literal: true

# Base class for census form configuration. Provides a DSL for describing census forms using "divider" and "input"
# commands. Implemented as singleton with each census year existing as a subclass.
class CensusFormFieldConfig
  class_attribute :inputs, :fields, :comments

  def self.input(field, **options)
    self.fields ||= []
    self.inputs ||= {}
    fields << field
    options[:inline_label] = 'Yes' if options[:as] == :boolean
    if %i[radio_buttons radio_buttons_other select].include?(options[:as])
      collection = census_record_class.try(:"#{field}_choices")
      options[:collection] ||= collection if collection
    end
    inputs[field] = options
  end

  def self.divider(title, **options)
    self.fields ||= []
    self.inputs ||= {}
    fields << title
    inputs[title] = options.merge({ as: :divider, label: title })
  end

  def self.options_for(field)
    inputs[field]
  rescue StandardError => error
    Rails.logger.error "*** Field Config Missing for #{field}! ***"
    raise error
  end

  def self.facets
    inputs.select { |_key, value| value[:as] != :divider && !value.key?(:facet) }.keys
  end

  def self.census_record_class
    to_s.sub(/FormFields/, 'Record').safe_constantize
  end
end
