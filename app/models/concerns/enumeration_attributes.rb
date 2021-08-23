# frozen_string_literal: true

module EnumerationAttributes
  def define_enumeration(name, values, strict=false)
    class_eval "def self.#{name}_choices; #{values.inspect}; end", __FILE__, __LINE__
    validates_inclusion_of name, in: values if strict
  end
end
