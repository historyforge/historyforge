# frozen_string_literal: true

module CensusRecords
  # Rebuilds the pg_search_documents rows related to the given table name's census.
  class RebuildPgSearchDocuments
    def self.call(table_name:, class_name:)
      new(table_name:, class_name:).call
    end

    def initialize(table_name:, class_name:)
      @table_name = table_name
      @class_name = class_name
    end

    def call
      connection.execute delete_sql
      connection.execute insert_sql
    end

    private

    attr_reader :table_name, :class_name

    def delete_sql
      <<~SQL.squish
        DELETE FROM pg_search_documents WHERE searchable_type='#{class_name}'
      SQL
    end

    def insert_sql
      <<~SQL.squish
        INSERT INTO pg_search_documents (searchable_type, searchable_id, content, created_at, updated_at)
          SELECT '#{class_name}' AS searchable_type,
                 id AS searchable_id,
                 CONCAT_WS(' ', searchable_name) AS content,
                 now() AS created_at,
                 now() AS updated_at
          FROM #{table_name}
          WHERE reviewed_at IS NOT NULL
      SQL
    end

    def connection
      ActiveRecord::Base.connection
    end
  end
end
