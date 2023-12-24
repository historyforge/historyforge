class CreateNameAuthorities < ActiveRecord::Migration[7.0]
  def change
    create_table :person_names do |t|
      t.references :person, null: false, foreign_key: true
      t.boolean :is_primary
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :name_prefix
      t.string :name_suffix
      t.string :searchable_name
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Person.find_each do |person|
          person.names.create(
            is_primary: true,
            first_name: person.read_attribute(:first_name),
            last_name: person.read_attribute(:last_name),
            middle_name: person.read_attribute(:middle_name),
            name_prefix: person.read_attribute(:name_prefix),
            name_suffix: person.read_attribute(:name_suffix)
          )
          person.census_records.each do |record|
            person.add_name_from!(record)
          end
        end
      end
    end
  end
end
