class AgeMonthsToBirthMonth < ActiveRecord::Migration[7.0]
  def up
    add_column :census1950_records, :birth_month, :integer, after: :age
    Census1950Record.find_each do |row|
      row.update_column :birth_month, row.age_months
    end
  end

  def down
    remove_column :census1950_records, :birth_month
  end
end
