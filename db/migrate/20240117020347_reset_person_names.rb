class ResetPersonNames < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE people
          SET first_name = person_names.first_name,
              middle_name = person_names.middle_name,
              last_name = person_names.last_name,
              searchable_name = person_names.searchable_name,
              name_prefix = person_names.name_prefix,
              name_suffix = person_names.name_suffix
          FROM person_names
          WHERE people.id=person_names.person_id AND person_names.is_primary=TRUE
        SQL
      end
    end
  end
end
