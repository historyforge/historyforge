class FinishRenamingAgeMonths1950 < ActiveRecord::Migration[7.0]
  def up
    remove_column :census1950_records, :age_months
    Census1950Record.update_all page_side: nil
  end

  def down
    add_column :census1950_records, :age_months, :integer, after: :age
  end
end
