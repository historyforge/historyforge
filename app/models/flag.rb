# == Schema Information
#
# Table name: flags
#
#  id             :integer          not null, primary key
#  flaggable_type :string
#  flaggable_id   :integer
#  user_id        :integer
#  reason         :string
#  message        :text
#  comment        :text
#  resolved_by_id :integer
#  resolved_at    :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_flags_on_flaggable_type_and_flaggable_id  (flaggable_type,flaggable_id)
#  index_flags_on_resolved_by_id                   (resolved_by_id)
#  index_flags_on_user_id                          (user_id)
#

# frozen_string_literal: true

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
