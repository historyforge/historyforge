# frozen_string_literal: true

class GenerateSourceNarrativeSearchText < ActiveRecord::Migration[7.2]
  def change
    Narrative.find_each(&:save)
  end
end
