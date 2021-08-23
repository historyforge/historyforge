# frozen_string_literal: true

# Base class for decorators. Implements method missing to return nil. Kinda dangerous but different census years
# have different fields. Sometimes people execute a query by changing the year in the URL. This causes it to try
# to output fields that don't exist. Instead of barfing let's just ignore the field.
class ApplicationDecorator < Draper::Decorator
  delegate_all

  def method_missing(method, *args)
    super
  rescue NoMethodError
    nil
  end

  def respond_to_missing?(method, include_private = nil)
    super
  end
end
