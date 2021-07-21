module AutoStripAttributes
  extend ActiveSupport::Concern
  included do
    class_attribute :autostrippable_attributes
    self.autostrippable_attributes ||= []
    class_attribute :autostrip_options
    self.autostrip_options = {}
    def self.auto_strip_attributes(*attributes)
      self.autostrip_options = AutoStripAttributes::Config.filters_enabled
      self.autostrip_options.merge!(attributes.pop) if attributes.last.is_a?(Hash)
      self.autostrippable_attributes += attributes

      before_validation :auto_strip_attributes
    end

    def auto_strip_attributes
      self.class.autostrippable_attributes.each do |attribute|
        value = self[attribute]
        AutoStripAttributes::Config.filters_order.each do |filter_name|
          next unless self.class.autostrip_options[filter_name]
          value = AutoStripAttributes::Config.filters[filter_name].call value
          self[attribute] = value
        end
      end
    end
  end
end

class AutoStripAttributes::Config
  class << self
    attr_accessor :filters
    attr_accessor :filters_enabled
    attr_accessor :filters_order
  end

  def self.setup(user_options=nil,&block)
    options = {
        :clear => false,
        :defaults => true,
    }
    options = options.merge user_options if user_options.is_a?(Hash)

    @filters, @filters_enabled, @filters_order = {}, {}, [] if options[:clear]

    @filters ||= {}
    @filters_enabled ||= {}
    @filters_order ||= []

    if options[:defaults]
      set_filter :remove_periods => true do |value|
        value.respond_to?(:gsub) ? value.gsub(/\./, "") : value
      end
      set_filter :convert_non_breaking_spaces => false do |value|
        value.respond_to?(:gsub) ? value.gsub("\u00A0", " ") : value
      end
      set_filter :strip => true do |value|
        value.respond_to?(:strip) ? value.strip : value
      end
      set_filter :nullify => true do |value|
        # We check for blank? and empty? because rails uses empty? inside blank?
        # e.g. MiniTest::Mock.new() only responds to .blank? but not empty?, check tests for more info
        # Basically same as value.blank? ? nil : value
        (value.respond_to?(:'blank?') and value.respond_to?(:'empty?') and value.blank?) ? nil : value
      end
      set_filter :squish => false do |value|
        value.respond_to?(:gsub) ? value.gsub(/\s+/, ' ') : value
      end
      set_filter :delete_whitespaces => false do |value|
        value.respond_to?(:delete) ? value.delete(" \t") : value
      end
    end

    instance_eval(&block) if block_given?
  end

  def self.set_filter(filter,&block)
    if filter.is_a?(Hash)
      filter_name = filter.keys.first
      filter_enabled = filter.values.first
    else
      filter_name = filter
      filter_enabled = false
    end
    @filters[filter_name] = block
    @filters_enabled[filter_name] = filter_enabled
    # in case filter is redefined, we probably don't want to change the order
    @filters_order << filter_name unless @filters_order.include? filter_name
  end
end

AutoStripAttributes::Config.setup
