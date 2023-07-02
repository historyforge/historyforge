# frozen_string_literal: true

class MergeEligibilityCheck
  def initialize(source, target)
    @source, @target = source, target
  end

  def perform
    @clashes = []
    @clashes << 1900 if @source.census1900_records.exists? && @target.census1900_records.exists?
    @clashes << 1910 if @source.census1910_records.exists? && @target.census1910_records.exists?
    @clashes << 1920 if @source.census1920_records.exists? && @target.census1920_records.exists?
    @clashes << 1930 if @source.census1930_records.exists? && @target.census1930_records.exists?
    @clashes << 1940 if @source.census1940_records.exists? && @target.census1940_records.exists?
    @clashes << 1950 if @source.census1940_records.exists? && @target.census1950_records.exists?
  end

  def okay?
    true # @clashes.blank?
  end

  def years
    @clashes
  end
end
