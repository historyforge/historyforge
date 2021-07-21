module Translator
  def self.label(klass, key)
    lookups = []
    lookups << :"#{klass.name.underscore}.#{key}"

    next_up = klass.superclass.name
    lookups << :"#{next_up.underscore}.#{key}" unless next_up == 'ApplicationRecord'

    lookups << :"defaults.#{key}"

    lookups << klass.human_attribute_name(key)

    I18n.t(lookups.shift, scope: 'simple_form.labels', default: lookups).presence
  end

  def self.option(attribute_name, item)
    I18n.t("#{attribute_name}.#{item.downcase.gsub(/\W/, '')}", scope: 'census_codes', default: item).presence
  end
end
