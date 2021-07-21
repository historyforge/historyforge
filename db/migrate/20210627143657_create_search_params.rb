class CreateSearchParams < ActiveRecord::Migration[6.0]
  def change
    create_table :search_params do |t|
      t.references :user, null: false, foreign_key: true
      t.string :model
      t.jsonb :params

      t.timestamps
    end
  end
end
