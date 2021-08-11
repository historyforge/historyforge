class CreateCensus1880Records < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        group = "1880 US Census"
        Setting.add "enabled_private_1880", type: :boolean, value: '0', group: group, name: 'Enabled Private', hint: 'This census year is available to logged-in users for data entry.'
        Setting.add "enabled_public_1880", type: :boolean, value: '0', group: group, name: 'Enabled Public', hint: 'This census year is available to the public for search.'
        Setting.add "add_buildings_1880", type: :boolean, value: '0', group: group, name: 'Add Buildings', hint: 'Allows census taker to create a new building from address.'
      end

      dir.down do
        Setting.where(group: "1880 US Census").delete_all
      end
    end

    create_table :census1880_records do |t|
      t.references :locality, foreign_key: true
      t.references :building, foreign_key: true
      t.references :person, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.integer :page_number
      t.string :page_side, limit: 1
      t.integer :line_number
      t.string :county
      t.string :city
      t.string :state
      t.string :ward
      t.string :enum_dist
      t.string :street_house_number
      t.string :street_prefix
      t.string :street_name
      t.string :street_suffix
      t.string :apartment_number
      t.string :dwelling_number
      t.string :family_id
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :name_prefix
      t.string :name_suffix
      t.string :sex
      t.string :race
      t.integer :age
      t.integer :age_months
      t.integer :birth_month
      t.string :relation_to_head
      t.string :marital_status
      t.boolean :just_married
      t.string :occupation, default: "None"
      t.integer :unemployed_months
      t.boolean :sick
      t.boolean :blind
      t.boolean :deaf_dumb
      t.boolean :idiotic
      t.boolean :insane
      t.boolean :maimed
      t.boolean :attended_school
      t.boolean :cannot_read
      t.boolean :cannot_write
      t.string :pob
      t.string :pob_father
      t.string :pob_mother
      t.text :notes

      t.boolean :provisional, default: false
      t.boolean :foreign_born, default: false
      t.boolean :taker_error, default: false
      t.integer :farm_schedule
      t.text :searchable_name
      t.uuid :histid
      t.timestamps
    end
  end
end
