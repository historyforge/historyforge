# frozen_string_literal: true

module People
  class MergeEligibilityCheck
    def initialize(source, target)
      @source = source
      @target = target
    end

    def perform
      @clashes = []
      CensusYears.each do |year|
        @clashes << year if record_for_year?(@source, year) && record_for_year?(@target, year)
      end
    end

    def record_for_year?(source, year)
      source.public_send("census#{year}_records").exists?
    end

    def okay?
      @clashes.blank?
    end

    def years
      @clashes
    end
  end
end
