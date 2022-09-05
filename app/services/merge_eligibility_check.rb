# frozen_string_literal: true

class MergeEligibilityCheck
  def initialize(source, target)
    @source, @target = source, target
  end

  def perform
    @clashes = []
    @clashes << 1900 if @source.census1900_record && @target.census1900_record
    @clashes << 1910 if @source.census1910_record && @target.census1910_record
    @clashes << 1920 if @source.census1920_record && @target.census1920_record
    @clashes << 1930 if @source.census1930_record && @target.census1930_record
  end

  def okay?
    @clashes.blank?
  end

  def years
    @clashes
  end
end
