# frozen_string_literal: true

class MergeEligibilityCheck
  def initialize(source, target)
    @source, @target = source, target
  end

  def perform
    @clashes = []
    @clashes << 1900 if @source.census1900_records && @target.census1900_records
    @clashes << 1910 if @source.census1910_records && @target.census1910_records
    @clashes << 1920 if @source.census1920_records && @target.census1920_records
    @clashes << 1930 if @source.census1930_records && @target.census1930_records
  end

  def okay?
    @clashes.blank?
  end

  def years
    @clashes
  end
end
