class FacebookAuthSettings < ActiveRecord::Migration[6.0]
  def self.up
    Setting.add 'facebook_login_enabled', type: :boolean, value: '0', group: 'Authentication', name: 'Enable Facebook Authentication', hint: 'Allow users to signup with their Facebook account.'
    Setting.add 'facebook_login_app_id', value: '',  group: 'Authentication'
    Setting.add 'facebook_login_secret', value: '', group: 'Authentication'
  end

  def self.down
    Setting.where(key: "facebook_login_enabled").delete_all
    Setting.where(key: "facebook_login_app_id").delete_all
    Setting.where(key: "facebook_login_secret").delete_all
  end
end
