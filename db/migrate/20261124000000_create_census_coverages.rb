# frozen_string_literal: true

class CreateCensusCoverages < ActiveRecord::Migration[7.2]
  def change
    create_table :census_coverages do |t|
      t.references :locality, null: false, foreign_key: true, index: false
      t.integer :census_year, null: false
      t.integer :expected_records, null: false
      t.string :target_basis, null: false
      t.string :source, null: false
      t.text :scope_note
      t.timestamps

      t.index %i[locality_id census_year], unique: true
      t.check_constraint 'expected_records > 0', name: 'census_coverages_positive_target'
    end
  end
end
