# frozen_string_literal: true

# Makes occupation codes like vx70 turn to VX70
module AutoUpcaseAttributes
  extend ActiveSupport::Concern
  included do
    class_attribute :autoupcaseable_attributes
    self.autoupcaseable_attributes ||= []

    def self.auto_upcase_attributes(*attributes)
      self.autoupcaseable_attributes += attributes

      before_validation :auto_upcase_attributes
    end

    def auto_upcase_attributes
      self.class.autoupcaseable_attributes.each do |attribute|
        self[attribute] = self[attribute].blank? ? nil : self[attribute].upcase
      end
    end
  end
end
