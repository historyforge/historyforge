module EnumerationAttributes
  def define_enumeration(name, values, strict=false)
    class_eval "def self.#{name}_choices; #{values.inspect}; end"
    if strict
      validates_inclusion_of name, in: values
    end
  end
end
