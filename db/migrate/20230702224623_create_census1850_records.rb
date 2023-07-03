class CreateCensus1850Records < ActiveRecord::Migration[7.0]
  def change
    create_table :census_1850_records do |t|
      t.references :locality, foreign_key: true
      t.references :building, foreign_key: true
      t.references :person, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime 'reviewed_at', precision: nil
      t.integer 'page_number'
      t.string 'page_side', limit: 1
      t.integer 'line_number'
      t.string 'county'
      t.string 'city'
      t.string 'institution_name'
      t.string 'institution_type'
      t.string 'state'
      t.string 'enum_dist', null: false
      t.integer 'ward'
      t.string 'street_house_number'
      t.string 'street_prefix'
      t.string 'street_name'
      t.string 'street_suffix'
      t.string 'apartment_number'
      t.string 'dwelling_number'
      t.string 'family_id'
      t.string 'last_name'
      t.string 'first_name'
      t.string 'middle_name'
      t.string 'name_prefix'
      t.string 'name_suffix'
      t.integer 'age'
      t.integer 'age_months'
      t.string 'sex'
      t.string 'race'
      t.string 'occupation', default: 'None'
      t.integer 'home_value'
      t.string 'pob'
      t.boolean 'just_married'
      t.boolean 'attended_school'
      t.boolean 'cannot_read_write'
      t.boolean 'deaf_dumb'
      t.boolean 'blind'
      t.boolean 'insane'
      t.boolean 'idiotic'
      t.boolean 'pauper'
      t.boolean 'convict'
      t.string 'nature_of_misfortune'
      t.integer 'year_of_misfortune'
      t.text 'notes'
      t.boolean 'foreign_born', default: false
      t.boolean 'taker_error', default: false
      t.integer 'farm_schedule'
      t.text 'searchable_name'
      t.uuid 'histid'

      t.timestamps
    end
  end
end
