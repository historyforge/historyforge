# frozen_string_literal: true

module CensusRecords
  # Supplies to CensusRecord model the methods needed for full-text search.
  module Searchable
    extend ActiveSupport::Concern
    included do
      include PgSearch::Model
      multisearchable against: :searchable_name,
                      using: {
                        tsearch: { prefix: true, any_word: true },
                        trigram: {}
                      },
                      if: :reviewed?
    end

    class_methods do
      def rebuild_pg_search_documents
        CensusRecords::RebuildPgSearchDocuments.run(class_name: name, table_name:)
      end
    end
  end
end
