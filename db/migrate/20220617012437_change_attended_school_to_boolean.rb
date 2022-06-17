class ChangeAttendedSchoolToBoolean < ActiveRecord::Migration[7.0]
  def up
    add_column :census1950_records, :attended_school_bool, :boolean, default: false, after: :attended_school
    Census1950Record.find_each do |row|
      if %w[V X].include? row.attended_school
        row.update_column :attended_school_bool, true
      end
    end
    remove_column :census1950_records, :attended_school
    rename_column :census1950_records, :attended_school_bool, :attended_school
  end

  def down
    raise "Can't go back"
  end
end
