module DefineEnumeration
  extend ActiveSupport::Concern
  included do
    class_attribute :enumerations
    def self.define_enumeration(name, values, strict=false)
      self.enumerations ||= []
      self.enumerations << name unless enumerations.include?(name)
      class_eval "def self.#{name}_choices; #{values.inspect}; end"
      if strict
        validates_inclusion_of name, in: values
      end
    end
  end
end
