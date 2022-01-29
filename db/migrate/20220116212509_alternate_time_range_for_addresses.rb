# frozen_string_literal: true

class AlternateTimeRangeForAddresses < ActiveRecord::Migration[6.1]
  def change
    remove_column :addresses, :year_earliest, :integer
    remove_column :addresses, :year_latest, :integer
    add_column :addresses, :year, :integer
  end
end
