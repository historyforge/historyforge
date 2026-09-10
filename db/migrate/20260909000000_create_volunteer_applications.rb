# frozen_string_literal: true

class CreateVolunteerApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :full_name, :string

    create_table :volunteer_applications do |t|
      t.references :user, type: :integer, foreign_key: { on_delete: :nullify }
      t.string :name, null: false
      t.string :email, null: false
      t.text :how_heard, null: false
      t.string :locality_names, array: true, default: [], null: false
      t.string :opportunity_interests, array: true, default: [], null: false
      t.string :experience
      t.text :experience_details
      t.text :other_interest
      t.text :comments
      t.string :status, null: false, default: 'submitted'
      t.text :staff_notes
      t.timestamps
    end
    add_index :volunteer_applications, [:status, :created_at]
    add_check_constraint :volunteer_applications, "status IN ('submitted', 'contacted', 'accepted', 'declined', 'archived')", name: 'volunteer_application_status'
    add_check_constraint :volunteer_applications, "experience IS NULL OR experience IN ('yes', 'no', 'maybe')", name: 'volunteer_application_experience'
  end
end
