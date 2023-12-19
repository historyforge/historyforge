# frozen_string_literal: true

class ChangePersonRaceColumnLimits < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :people, :race, :string, limit: nil
      end
      dir.down do
        change_column :people, :race, :string, limit: 12
      end
    end
  end
end
