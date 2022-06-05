# frozen_string_literal: true

class Translator
  def self.label(klass, key)
    # DataDictionary.label key, klass.name.scan(/\d{4}/)
    translate(klass, key, 'labels')
  end

  def self.filter(klass, key)
    # DataDictionary.label key, klass.name.scan(/\d{4}/)
    translate(klass, key, 'filters') || label(klass, key)
  end

  def self.hint(klass, key)
    # DataDictionary.hint key, klass.name.scan(/\d{4}/)
    translate(klass, key, 'hints')
  end

  def self.translate(klass, key, namespace)
    new(klass, key, namespace).translate
  end

  def self.option(attribute_name, item)
    # DataDictionary.census_code attribute_name, item
    I18n.t("#{attribute_name}.#{item.downcase.gsub(/\W/, '')}", scope: 'census_codes', default: item).presence
  end

  attr_reader :klass, :key, :namespace

  def initialize(klass, key, namespace)
    @klass = klass
    @key = key
    @namespace = namespace
  end

  def translate
    I18n.t(lookups.shift, scope: "simple_form.#{namespace}", default: lookups).presence
  end

  def lookups
    return @lookups if defined?(@lookups)

    @lookups = [
      this_class_lookup,
      super_class_lookup,
      fallback_lookup
    ].compact
  end

  private

  def this_class_lookup
    :"#{klass.name.underscore}.#{key}"
  end

  def super_class_lookup
    next_up = klass.superclass.name
    next_up == 'ApplicationRecord' ? nil : :"#{next_up.underscore}.#{key}"
  end

  def fallback_lookup
    if namespace == 'labels'
      klass.try(:human_attribute_name, key) || key.to_s.humanize.titleize
    else
      ''
    end
  end
end
