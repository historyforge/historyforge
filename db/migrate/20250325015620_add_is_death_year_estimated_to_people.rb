# frozen_string_literal: true

class AddIsDeathYearEstimatedToPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :people, :is_death_year_estimated, :boolean, default: true
  end
end
