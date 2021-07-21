class DropGisStuff < ActiveRecord::Migration[6.0]
  def change
    execute "DROP EXTENSION IF EXISTS postgis"
    execute "DROP TABLE IF EXISTS spatial_ref_sys"
  end
end
