# == Schema Information
#
# Table name: audit_logs
#
#  id            :bigint           not null, primary key
#  loggable_type :string
#  loggable_id   :integer
#  user_id       :bigint
#  message       :string
#  logged_at     :datetime
#
# Indexes
#
#  index_audit_logs_on_loggable_type_and_loggable_id  (loggable_type,loggable_id)
#  index_audit_logs_on_user_id                        (user_id)
#
require 'rails_helper'

RSpec.describe AuditLog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
