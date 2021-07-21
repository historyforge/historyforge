module Moderation
  extend ActiveSupport::Concern
  included do
    belongs_to :created_by, class_name: 'User', optional: true
    belongs_to :reviewed_by, class_name: 'User', optional: true

    def reviewed?
      reviewed_at.present?
    end

    scope :reviewed, -> { where "reviewed_at IS NOT NULL" }
    scope :unreviewed, -> { where(reviewed_at: nil) }
    scope :recently_added, -> { where "created_at >= ?", 3.months.ago }
    scope :recently_reviewed, -> { where "reviewed_at >= ?", 3.months.ago }
  end

  def review!(reviewer)
    return if reviewed?
    self.reviewed_at = Time.now
    self.reviewed_by = reviewer
    unless save
      self.reviewed_at = nil
      self.reviewed_by = nil
    end
    self
  end

  def prepare_for_review
    return if reviewed?
    self.reviewed_at = Time.now
    validate
    self.reviewed_at = nil
  end

  def reviewed?
    reviewed_at.present?
  end
end
