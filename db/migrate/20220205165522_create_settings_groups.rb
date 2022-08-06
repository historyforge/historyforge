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

        Setting.add 'facebook_login_enabled', type: :boolean, value: '0', group: 'Authentication', name: 'Enable Facebook Authentication', hint: 'Allow users to signup with their Facebook account.'
        Setting.add 'facebook_login_app_id', value: '',  group: 'Authentication'
        Setting.add 'facebook_login_secret', value: '', group: 'Authentication'
      end
    end
  end
end
