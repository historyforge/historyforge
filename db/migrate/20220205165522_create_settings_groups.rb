class CreateSettingsGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :settings_groups do |t|
      t.string :name

      t.timestamps
    end

    change_table :settings do |t|
      t.references :settings_group, foreign_key: true
    end

    reversible do |dir|
      dir.up do
        Setting.find_each do |setting|
          group = SettingsGroup.find_or_create_by(name: setting.read_attribute(:group))
          setting.group = group
          setting.save!
        end
      end
    end
  end
end
