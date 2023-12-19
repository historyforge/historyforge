class ChangePersonRaceSexColumnLimits < ActiveRecord::Migration[7.0]
  def change
    change_column :people, :race, :string, limit: nil
    change_column :people, :sex, :string, limit: nil
  end
end
