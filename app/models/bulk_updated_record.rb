# == Schema Information
#
# Table name: bulk_updated_records
#
#  id             :bigint           not null, primary key
#  bulk_update_id :bigint
#  record_type    :string
#  record_id      :bigint
#
# Indexes
#
#  index_bulk_updated_records_on_bulk_update_id             (bulk_update_id)
#  index_bulk_updated_records_on_record_type_and_record_id  (record_type,record_id)
#

# frozen_string_literal: true

class BulkUpdatedRecord < ApplicationRecord
  belongs_to :bulk_update, inverse_of: :records
  belongs_to :record, polymorphic: true, inverse_of: :bulk_updated_records
end
