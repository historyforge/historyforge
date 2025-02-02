# frozen_string_literal: true

# This used to be an ActiveRecord model from the MapWarper days. It is now a bitmask model to make storage and
# lookup more efficient.
class Role < BitmaskModel
  def self.current
    all.reject { |role| role.name == 'Photographer' }
  end

  self.data = [
    'Administrator',
    'Editor',
    'Reviewer',
    'Photographer',
    'Census Taker',
    'Builder',
    'Person Record Editor',
    'Content Editor'
  ]

  self.descriptions = [
    'Administrators can do anything. They are the only ones who can delete anything.',
    'Editors can create and edit any census record.',
    'Reviewers can review any census record, building, or photograph.',
    'Photographers can create and edit any photograph records.',
    'Census takers can add new census records and edit the ones they created.',
    'Builders can create and edit any building records.',
    'Person Record editors can edit person records.',
    'Content Editors can do anything with user generated content - photographs, audios, videos, and source narratives.'
  ]
end
