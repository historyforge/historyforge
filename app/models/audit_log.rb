# frozen_string_literal: true

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
class AuditLog < ApplicationRecord
  belongs_to :loggable, polymorphic: true
  belongs_to :user, optional: true
  validates :message, presence: true
  alias_attribute :created_at, :logged_at

  before_validation do
    self.user_id ||= PaperTrail.request.whodunnit
    self.logged_at ||= Time.current
  end

  def whodunnit
    user_id.to_s
  end
end

