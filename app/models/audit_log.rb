# frozen_string_literal: true

class AuditLog < ApplicationRecord
  belongs_to :loggable, polymorphic: true
  belongs_to :user, optional: true
  validates :message, presence: true
  alias_attribute :created_at, :logged_at

  before_validation do
    self.user_id ||= PaperTrail.request.whodunnit
    self.logged_at ||= Time.now
  end

  def whodunnit
    user_id&.to_s
  end
end

