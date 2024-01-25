# frozen_string_literal: true

module Moderation
  extend ActiveSupport::Concern
  included do
    belongs_to :created_by, class_name: 'User', optional: true
    belongs_to :reviewed_by, class_name: 'User', optional: true

    def reviewed?
      reviewed_at.present?
    end

    scope :reviewed, -> { where.not(reviewed_at_column => nil) }
    scope :unreviewed, -> { where(reviewed_at_column => nil) }
    scope :recently_added, -> { where 'created_at >= ?', 3.months.ago }
    scope :recently_reviewed, -> { where 'reviewed_at >= ?', 3.months.ago }

    def self.reviewed_at_column
      "#{current_table_name}.reviewed_at"
    end
  end

  def review!(reviewer)
    return if reviewed?

    self.reviewed_at = Time.current
    self.reviewed_by = reviewer

    unless save
      self.reviewed_at = nil
      self.reviewed_by = nil
    end
    self
  end

  def prepare_for_review
    return if reviewed?

    self.reviewed_at = Time.current
    validate
    self.reviewed_at = nil
  end

  def reviewed?
    reviewed_at.present?
  end
end
