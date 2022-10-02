# frozen_string_literal: true

class Role < BitmaskModel
  self.data = [
    'Administrator',
    'Editor',
    'Reviewer',
    'Photographer',
    'Census Taker',
    'Builder'
  ]

  self.descriptions = [
    'Administrators can do anything. They are the only ones who can delete anything.',
    'Editors can create and edit any census record.',
    'Reviewers can review any census record, building, or photograph.',
    'Photographers can create and edit any photograph records.',
    'Census takers can add new census records and edit the ones they created.',
    'Builders can create and edit any building records.'
  ]
end
