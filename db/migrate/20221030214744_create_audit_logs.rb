class CreateAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_logs do |t|
      t.string :loggable_type
      t.integer :loggable_id
      t.references :user, foreign_key: true
      t.string :message
      t.datetime :logged_at
    end

    change_table :audit_logs do |t|
      t.index [:loggable_type, :loggable_id]
    end
  end
end
