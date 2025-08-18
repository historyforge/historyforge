# frozen_string_literal: true

# Centralizes the means to iterate all census years
module CensusYears
  YEARS = [1850, 1860, 1870, 1880, 1900, 1910, 1920, 1930, 1940, 1950].freeze

  YEARS_IN_WORDS = %w[
    eighteen_fifty eighteen_sixty eighteen_seventy eighteen_eighty nineteen_aught nineteen_ten
    nineteen_twenty nineteen_thirty nineteen_forty nineteen_fifty
  ].freeze

  YEAR_CLASSES = {
    1850 => Census1850Record,
    1860 => Census1860Record,
    1870 => Census1870Record,
    1880 => Census1880Record,
    1900 => Census1900Record,
    1910 => Census1910Record,
    1920 => Census1920Record,
    1930 => Census1930Record,
    1940 => Census1940Record,
    1950 => Census1950Record
  }.freeze

  def self.class_for(year)
    YEAR_CLASSES[year.to_i]
  end

  def self.each
    YEARS.each_with_index do |year, index|
      words = YEARS_IN_WORDS[index]
      yield year, words
    end
  end

  def each_class
    YEARS.each do |year|
      yield class_for(year)
    end
  end

  def self.map(&block)
    YEARS.map(&block)
  end

  def self.sum(&block)
    YEARS.map(&block).reduce(&:+)
  end

  def self.to_words(year)
    YEARS_IN_WORDS[YEARS.index(year)]
  end

  def self.visible_to_user(user)
    YEARS.select { |year| Setting.can_view_public?(year) || (user && Setting.can_view_private?(year)) }
  end

  def self.each_visible_to_user(user, &block)
    visible_to_user(user).each(&block)
  end

  def self.lte(year)
    YEARS.select { |y| y <= year }
  end

  def self.gt(year)
    YEARS.select { |y| y > year }
  end
end
