# frozen_string_literal: true

# Centralizes the means to iterate all census years
module CensusYears
  YEARS = [1900, 1910, 1920, 1930, 1940]

  def self.each(&block)
    YEARS.each(&block)
  end

  def self.map(&block)
    YEARS.map(&block)
  end
end
