# frozen_string_literal: true

class AddMissingCensusSummarySettings < ActiveRecord::Migration[8.1]
  def up
    CensusYears.each { |year| Setting.add_census_summary_settings(year) }
  end

  def down
    # Keep existing site visibility preferences when rolling back.
  end
end
