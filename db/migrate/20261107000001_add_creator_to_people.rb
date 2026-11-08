# frozen_string_literal: true

class AddCreatorToPeople < ActiveRecord::Migration[8.0]
  def up
    add_reference :people, :created_by, index: false

    execute <<~SQL
      UPDATE people
      SET created_by_id = creations.operator_id
      FROM (
        SELECT DISTINCT ON (item_id) item_id, whodunnit::bigint AS operator_id
        FROM versions
        WHERE item_type = 'Person' AND event = 'create'
          AND whodunnit ~ '^[1-9][0-9]{0,9}$'
        ORDER BY item_id, id
      ) AS creations
      WHERE people.id = creations.item_id
    SQL

    add_index :people, :created_by_id
    remove_index :versions, name: :index_versions_on_person_creation_operator
  end

  def down
    add_index :versions, %i[whodunnit item_id],
              name: :index_versions_on_person_creation_operator,
              where: "item_type = 'Person' AND event = 'create'"
    remove_reference :people, :created_by
  end
end
