# frozen_string_literal: true

class AddYearOfStreetRenumberingToLocality < ActiveRecord::Migration[6.1]
  def change
    add_column :localities, :year_street_renumber, :integer
  end
end
