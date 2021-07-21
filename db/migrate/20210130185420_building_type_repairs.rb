class BuildingTypeRepairs < ActiveRecord::Migration[6.0]
  def up
    Building.find_each do |row|
      next if row.building_type_id.blank?
      next if row.building_type_ids.include?(row.building_type_id)

      row.building_type_ids << row.building_type_id
    end
  end

  def down
  end
end
