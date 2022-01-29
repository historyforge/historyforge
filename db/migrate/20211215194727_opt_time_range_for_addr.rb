# frozen_string_literal: true

class OptTimeRangeForAddr < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :year_earliest, :integer
    add_column :addresses, :year_latest, :integer
  end
end
