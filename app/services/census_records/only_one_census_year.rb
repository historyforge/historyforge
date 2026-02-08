# frozen_string_literal: true

module CensusRecords
  # Checks if the system only has data for a single census year.
  # Returns true if at most one census year has any records.
  #
  # Used to determine if cross-census operations (like matching people across
  # multiple censuses) are possible, or if it's safe to auto-generate person
  # records without risk of duplicates across census years.
  module OnlyOneCensusYear
    def self.call
      CensusYears.sum { |year| "Census#{year}Record".constantize.count.positive? ? 1 : 0 } <= 1
    end
  end
end
