class Flag < ApplicationRecord
  attr_reader :mark_resolved
  attr_accessor :editing_user
  belongs_to :flaggable, polymorphic: true
  belongs_to :flagged_by, class_name: 'User', foreign_key: :user_id, optional: true
  belongs_to :resolved_by, class_name: 'User', optional: true

  validates :reason, :message, presence: true

  scope :unresolved, -> { where(resolved_at: nil) }

  REASONS = { incorrect: 'Incorrect data',
              inappropriate: 'Inappropriate content',
              duplicate: 'Possible duplicate' }

  def self.reason_choices
    REASONS.map { |k, v| [v, k] }
  end

  def resolved?
    resolved_at.present?
  end

  def mark_resolved=(value)
    if value == '1'
      self.resolved_by = editing_user
      self.resolved_at = Time.now
    end
  end

  def display_reason
    REASONS[reason.intern]
  end
end
