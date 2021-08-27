class ConvertBuildingDescription < ActiveRecord::Migration[6.0]
  include ActionView::Helpers::TextHelper
  def change
    reversible do |dir|
      dir.up do
        Building.find_each do |building|
          desc = building.read_attribute(:description)
          next if desc.blank?

          building.update(description: simple_format(desc))
        end
      end
    end
  end
end
