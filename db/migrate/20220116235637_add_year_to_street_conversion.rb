class AddYearToStreetConversion < ActiveRecord::Migration[6.1]
  def change
    add_column :street_conversions, :year, :integer
  end
end
