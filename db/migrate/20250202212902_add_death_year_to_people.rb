# frozen_string_literal: true

class AddDeathYearToPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :people, :death_year, :integer
  end
end
