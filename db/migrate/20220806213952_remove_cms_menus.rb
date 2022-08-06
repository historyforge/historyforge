class RemoveCmsMenus < ActiveRecord::Migration[7.0]
  def change
    drop_table :cms_menu_items
    drop_table :cms_menus
    drop_table :oauth_nonces
    drop_table :oauth_tokens
  end
end
