class ConnectBulkUpdatesToRecordsChanged < ActiveRecord::Migration[6.0]
  def change
    create_table :bulk_updated_records do |t|
      t.references :bulk_update, foreign_key: true
      t.references :record, polymorphic: true
    end
  end
end
