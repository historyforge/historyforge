class BulkUpdatedRecord < ApplicationRecord
  belongs_to :bulk_update
  belongs_to :record, polymorphic: true
end