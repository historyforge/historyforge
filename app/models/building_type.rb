# frozen_string_literal: true

# Data dictionary for building types. Since a building can have many building types, it is a structured
# as a bitmask.
class BuildingType < BitmaskModel
  # You can add to this list but if you reorder or remove items, you will screw up the data
  self.data = %w[Public Marker Residence Religious Commercial Cemetery Institution Plantation].freeze
end
