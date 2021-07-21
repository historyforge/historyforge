class PersonRecordSizeTooShort < ActiveRecord::Migration[6.0]
  def change
    change_column :people, :sex, :string, limit: 12
  end
end
