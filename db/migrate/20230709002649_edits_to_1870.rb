class EditsTo1870 < ActiveRecord::Migration[7.0]
  def change
    change_table :census_1870_records do |t|
      t.remove :just_born, :just_married, :pauper, :convict
      t.integer :birth_month
      t.integer :marriage_month
    end
  end
end
