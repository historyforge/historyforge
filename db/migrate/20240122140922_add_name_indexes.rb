class AddNameIndexes < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :sortable_name, :string, after: :searchable_name
    add_column :person_names, :sortable_name, :string, after: :searchable_name
    CensusYears.each do |year|
      table_name = :"census_#{year}_records"
      add_column table_name, :sortable_name, :string, after: :searchable_name, index: true
    end
    reversible do |dir|
      dir.up do
        execute "UPDATE people SET sortable_name=concat_ws(' ', lower(last_name), lower(first_name), lower(middle_name))"
        execute "UPDATE person_names SET sortable_name=concat_ws(' ', lower(last_name), lower(first_name), lower(middle_name))"
        CensusYears.each do |year|
          table_name = :"census_#{year}_records"
          execute "UPDATE #{table_name} SET sortable_name=concat_ws(' ', lower(last_name), lower(first_name), lower(middle_name))"
        end
      end
    end
  end
end
