# frozen_string_literal: true

class DefaultDeathYearToExact < ActiveRecord::Migration[7.2]
  def change
    change_column_default :people, :is_death_year_estimated, from: true, to: false
  end
end
