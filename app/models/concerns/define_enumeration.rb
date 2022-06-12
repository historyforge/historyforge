# frozen_string_literal: true

module DefineEnumeration
  extend ActiveSupport::Concern
  included do
    class_attribute :enumerations

    # Defines an enumerated list for use by the model. Most such lists are of census codes, such as M or F, B and W.
    # Strict means only allow values on the list for this attribute.
    def self.define_enumeration(name, values, **kwargs)
      strict = kwargs[:strict]
      self.enumerations ||= []

      class_eval "def self.#{name}_choices; #{values.inspect}; end", __FILE__, __LINE__

      if enumerations.include?(name)
        _replace_inclusion_validator(name, values) if strict
      else
        self.enumerations << name
        class_eval "validates_inclusion_of :#{name}, in: #{name}_choices#{kwargs[:if] ? ", if: :#{kwargs[:if]}" : ""}", __FILE__, __LINE__ if strict
      end
    end

    # This is necessary because if CensusRecord defines page_side as A or B, and then 1880 says A through D, then
    # it will have both validations. This lets us clear the old list and replace it with the new list. If a future
    # version of Rails causes the issue to crop up, it may be in the way that ActiveRecord stores validators.
    def self._replace_inclusion_validator(attr, values)
      validator = _validators[attr]&.detect { |v| v.is_a?(ActiveModel::Validations::InclusionValidator) }
      if validator
        validator.instance_variable_set(:"@options", { in: values })
        validator.instance_variable_set(:"@delimiter", values)
      end
    end
  end
end
