# frozen_string_literal: true

# Modified version of ye old auto_strip_attributes gem, with some extra filters and some gunk removed
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
