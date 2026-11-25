# frozen_string_literal: true

class AddVerificationToCensusCoverages < ActiveRecord::Migration[7.2]
  def change
    add_column :census_coverages, :verified_at, :datetime
    add_column :census_coverages, :verification_note, :text
    add_reference :census_coverages, :verified_by, index: false,
                  foreign_key: { to_table: :users, on_delete: :nullify, name: 'census_coverages_verified_by_fk' }
  end
end
