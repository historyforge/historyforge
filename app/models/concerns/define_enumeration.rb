module DefineEnumeration
  extend ActiveSupport::Concern
  included do
    class_attribute :enumerations
    def self.define_enumeration(name, values, strict = false)
      self.enumerations ||= []

      class_eval "def self.#{name}_choices; #{values.inspect}; end", __FILE__, __LINE__

      if enumerations.include?(name)
        replace_inclusion_validator(name, values) if strict
      else
        self.enumerations << name
        class_eval "validates_inclusion_of :#{name}, in: #{name}_choices", __FILE__, __LINE__ if strict
      end
    end

    def self.replace_inclusion_validator(attr, values)
      validator = _validators[attr]&.detect { |v| v.is_a?(ActiveModel::Validations::InclusionValidator) }
      if validator
        validator.instance_variable_set(:"@options", { in: values })
        validator.instance_variable_set(:"@delimiter", values)
      end
    end
  end
end
