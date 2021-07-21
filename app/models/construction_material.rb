class ConstructionMaterial < ApplicationRecord
  validates :name, :color, presence: true
end
