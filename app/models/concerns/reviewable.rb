module Reviewable
  extend ActiveSupport::Concern

  included do
    belongs_to :reviewed_by, class_name: 'User', optional: true
    scope :reviewed, -> { where.not(reviewed_at: nil) }
  end

end
