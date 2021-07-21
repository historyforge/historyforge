class AddHouseNumberToStreetConversion < ActiveRecord::Migration[6.0]
  def change
    change_table :street_conversions do |t|
      t.string :from_house_number
      t.string :to_house_number
    end
  end
end
