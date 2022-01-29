class BuildingTypesBitmask < ActiveRecord::Migration[6.0]
  def change
    add_column :buildings, :building_types_mask, :integer
    reversible do |dir|
      dir.up do
        building_type_ids = BuildingType.all.map(&:id)
        building_types = BuildingType.all.each_with_object({}) { |type, obj| obj[type.name] = type.id }
        old_building_types = ActiveRecord::Base.connection
                                               .execute('select id, name from building_types')
                                               .to_a
                                               .each_with_object({}) { |type, obj| obj[type['id']] = type['name'].capitalize }
        Building.find_each do |row|
          sql = "SELECT building_type_id FROM buildings_building_types WHERE building_id=#{row.id}"
          names = ActiveRecord::Base.connection.execute(sql).map { |item| old_building_types[item['building_type_id']] }
          ids = names.map { |name| building_types[name] }
          row.update_column :building_types_mask, (building_type_ids & ids).map { |id| 2**id }.sum
        end
      end
    end
  end
end
