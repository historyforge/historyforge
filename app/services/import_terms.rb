# frozen_string_literal: true

class ImportTerms
  def initialize(file, vocabulary)
    require 'csv'
    @file = file.path
    @vocabulary = vocabulary
    @found = 0
    @added = 0
  end

  attr_reader :found, :added

  def run
    CSV.foreach(@file, headers: false) do |row|
      name = row[0]
      term = @vocabulary.terms.find_or_initialize_by(name: name)
      if term.new_record?
        term.save
        @added += 1
      else
        @found += 1
      end
    end
  end
end