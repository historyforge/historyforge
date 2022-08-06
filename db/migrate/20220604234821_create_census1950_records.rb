class CreateCensus1950Records < ActiveRecord::Migration[7.0]
  def change
    create_table :census1950_records do |t|
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
      t.integer :ward
      t.integer :enum_dist
      t.string :institution_name
      t.string :institution_type
      t.string :apartment_number
      t.string :street_prefix
      t.string :street_name
      t.string :street_suffix
      t.string :street_house_number
      t.string :dwelling_number
      t.string :family_id

      t.boolean :lives_on_farm
      t.boolean :lives_on_3_acres
      t.string :ag_questionnaire_no
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :name_prefix
      t.string :name_suffix
      t.text :searchable_name

      t.string :relation_to_head
      t.string :race
      t.string :sex
      t.integer :age
      t.integer :age_months
      t.string :marital_status

      t.string :pob
      t.boolean :foreign_born, default: false
      t.string :naturalized_alien

      t.string :activity_last_week
      t.boolean :worked_last_week
      t.boolean :seeking_work
      t.boolean :employed_absent
      t.integer :hours_worked
      t.string :occupation, default: 'None'
      t.string :industry
      t.string :worker_class
      t.string :occupation_code
      t.string :industry_code
      t.string :worker_class_code

      t.boolean :same_house_1949
      t.boolean :on_farm_1949
      t.boolean :same_county_1949
      t.string :county_1949
      t.string :state_1949

      t.string :pob_father
      t.string :pob_mother

      t.string :highest_grade
      t.boolean :finished_grade
      t.string :attended_school

      t.integer :weeks_seeking_work
      t.integer :weeks_worked
      t.string :wages_or_salary_self
      t.string :own_business_self
      t.string :unearned_income_self
      t.string :wages_or_salary_family
      t.string :own_business_family
      t.string :unearned_income_family

      t.boolean :veteran_ww2
      t.boolean :veteran_ww1
      t.boolean :veteran_other

      t.boolean :item_20_entries
      t.string :last_occupation
      t.string :last_industry
      t.string :last_worker_class

      t.boolean :multi_marriage
      t.integer :years_married
      t.boolean :newlyweds
      t.integer :children_born

      t.text :notes
      t.boolean :provisional, default: false
      t.boolean :taker_error, default: false
      t.uuid :histid
      t.timestamps
    end
  end
end
