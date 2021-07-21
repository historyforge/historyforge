module JsonData
  extend ActiveSupport::Concern
  included do

    include ArDocStore::Model
    # momentary hack because Ruby 2.0.0 const_defined? doesn't behave well with ::
    def self.attribute(name, *args)
      type = args.shift if args.first.is_a?(Symbol)
      options = args.extract_options!
      type ||= options.delete(:as) || :string
      class_name = ArDocStore.mappings[type] || "ArDocStore::AttributeTypes::#{type.to_s.classify}Attribute"
      # raise "Invalid attribute type: #{class_name}" unless const_defined?(class_name)
      class_name.constantize.build self, name, options
      define_virtual_attribute_method name
      define_method "#{name}?", -> { public_send(name).present? }
    end

  end
end
