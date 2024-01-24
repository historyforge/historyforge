# frozen_string_literal: true

module CensusRecords
  class SingleCensus < ApplicationInteraction
    def execute
      CensusYears.sum { |year| "Census#{year}Record".constantize.count.positive? ? 1 : 0 } <= 1
    end
  end
end
