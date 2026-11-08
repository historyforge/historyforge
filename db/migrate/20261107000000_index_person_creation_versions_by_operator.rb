# frozen_string_literal: true

class IndexPersonCreationVersionsByOperator < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :versions, %i[whodunnit item_id],
              name: :index_versions_on_person_creation_operator,
              where: "item_type = 'Person' AND event = 'create'",
              algorithm: :concurrently
  end
end
