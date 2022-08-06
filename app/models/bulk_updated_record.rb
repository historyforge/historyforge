# == Schema Information
#
# Table name: bulk_updated_records
#
#  id             :integer          not null, primary key
#  bulk_update_id :integer
#  record_type    :string
#  record_id      :integer
#
# Indexes
#
#  index_bulk_updated_records_on_bulk_update_id             (bulk_update_id)
#  index_bulk_updated_records_on_record_type_and_record_id  (record_type,record_id)
#

# frozen_string_literal: true

class BulkUpdatedRecord < ApplicationRecord
  belongs_to :bulk_update
  belongs_to :record, polymorphic: true
end
