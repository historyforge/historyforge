# frozen_string_literal: true

# Removes empty space from string columns, and converts "" to nil.
module AutoStripAttributes
  extend ActiveSupport::Concern
  included do
    before_validation :auto_strip_attributes

    def self.text_columns
      @text_columns ||= columns.select { |col_def| col_def.type == :string }.map(&:name)
    end

    def auto_strip_attributes
      self.class.text_columns.each do |attribute|
        value = self[attribute]&.squish
        self[attribute] = value.blank? ? nil : value
      end
    end
  end
end
