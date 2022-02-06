# frozen_string_literal: true

# Base class for decorators. Implements method missing to return nil. Kinda dangerous but different census years
# have different fields. Sometimes people execute a query by changing the year in the URL. This causes it to try
# to output fields that don't exist. Instead of barfing let's just ignore the field.
class ApplicationDecorator
  def self.decorate(object, options = nil)
    new(object, options)
  end

  def initialize(object, options = nil)
    @object = object
    @options = options
  end

  attr_reader :object
  delegate_missing_to(:object)
end
