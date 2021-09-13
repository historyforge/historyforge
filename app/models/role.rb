class Role < BitmaskModel
  # has_many :permissions
  # has_many :users, through: :permissions

  # Role.find_or_create_by name: 'administrator'
  # Role.find_or_create_by name: 'editor'
  # Role.find_or_create_by name: 'reviewer'
  # Role.find_or_create_by name: 'photographer'
  # Role.find_or_create_by name: 'census taker'
  # Role.find_or_create_by name: 'builder'

  self.data = [
    'Administrator',
    'Editor',
    'Reviewer',
    'Photographer',
    'Census Taker',
    'Builder'
  ]
end
