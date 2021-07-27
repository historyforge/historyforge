# frozen_string_literal: true

# Modified version of ye old auto_strip_attributes gem, with some extra filters and some gunk removed
module AutoStripAttributes
  extend ActiveSupport::Concern
  included do
    class_attribute :autostrippable_attributes
    self.autostrippable_attributes ||= []

    def self.auto_strip_attributes(*attributes)
      self.autostrippable_attributes += attributes

      before_validation :auto_strip_attributes
    end

    def auto_strip_attributes
      self.class.autostrippable_attributes.each do |attribute|
        AutoStripAttributes::Config.each_filter do |filter|
          self[attribute] = filter.call self[attribute]
        end
      end
    end
  end

  class Config
    class << self
      attr_accessor :filters, :filters_order

      def setup
        set_filter :remove_periods do |value|
          value.respond_to?(:gsub) ? value.gsub(/\./, '') : value
        end
        set_filter :strip do |value|
          value.respond_to?(:strip) ? value.strip : value
        end
        set_filter :nullify do |value|
          # We check for blank? and empty? because rails uses empty? inside blank?
          # e.g. MiniTest::Mock.new() only responds to .blank? but not empty?, check tests for more info
          # Basically same as value.blank? ? nil : value
          value.respond_to?(:'blank?') && value.respond_to?(:'empty?') && value.blank? ? nil : value
        end
      end

      def set_filter(filter, &block)
        @filters ||= {}
        @filters_order ||= []

        @filters[filter] = block
        # in case filter is redefined, we probably don't want to change the order
        @filters_order << filter unless @filters_order.include? filter
      end

      def each_filter
        filters_order.each do |filter_name|
          yield filters[filter_name]
        end
      end
    end
  end
end

AutoStripAttributes::Config.setup
