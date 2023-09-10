# frozen_string_literal: true

class MergeEligibilityCheck
  def initialize(source, target)
    @source, @target = source, target
  end

  def perform
    @clashes = []
    Census.years.each do |year|
      @clashes << year if has_record_for_year?(@source, year) && has_record_for_year?(@target, year)
    end
  end

  def has_record_for_year?(source, year)
    source.public_send("census#{year}_records").exists?
  end

  def okay?
    @clashes.blank?
  end

  def years
    @clashes
  end
end
