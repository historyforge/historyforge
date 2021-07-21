class CreateIpumsRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :ipums_records, id: false do |t|
      t.uuid :histid, primary_key: true, index: true
      t.integer :serial
      t.integer :year
      t.jsonb :data

      t.timestamps
    end
  end
end
