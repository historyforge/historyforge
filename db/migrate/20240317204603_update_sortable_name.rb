class UpdateSortableName < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        CensusYears.each do |year|
          execute "UPDATE census_#{year}_records set sortable_name=concat_ws(',', last_name, first_name, middle_name)"
        end
        execute "UPDATE people set sortable_name=concat_ws(',', last_name, first_name, middle_name)"
      end
    end
  end
end
