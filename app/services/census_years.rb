# frozen_string_literal: true

# Centralizes the means to iterate all census years
module CensusYears
  YEARS = [1880, 1900, 1910, 1920, 1930, 1940].freeze
  YEARS_IN_WORDS = %w[
    eighteen_eighty nineteen_aught nineteen_ten nineteen_twenty nineteen_thirty nineteen_forty
  ].freeze

  def self.each
    YEARS.each_with_index do |year, index|
      words = YEARS_IN_WORDS[index]
      yield year, words
    end
  end

  def self.map(&block)
    YEARS.map(&block)
  end

  def self.to_words(year)
    YEARS_IN_WORDS[YEARS.index(year)]
  end

  def self.visible_to_user(user)
    YEARS.select { |year| Setting.can_view_public?(year) || (user && Setting.can_view_private?(year)) }
  end

  def self.each_visible_to_user(user, &block)
    visible_to_user(user).each do |year|
      yield year
    end
  end
end
