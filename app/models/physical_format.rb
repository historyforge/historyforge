class PhysicalFormat < ApplicationRecord
  has_and_belongs_to_many :physical_types
end
