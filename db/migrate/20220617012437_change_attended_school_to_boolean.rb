class ChangeAttendedSchoolToBoolean < ActiveRecord::Migration[7.0]
  def up
    add_column :census1950_records, :attended_school_bool, :boolean, default: false, after: :attended_school
    Census1950Record.find_each do |row|
      next unless row.attended_school && row.attended_school != 'N'
      row.update_column :attended_school_bool, true
    end
    remove_column :census1950_records, :attended_school
    rename_column :census1950_records, :attended_school_bool, :attended_school
  end

  def down
    raise "Can't go back"
  end
end
