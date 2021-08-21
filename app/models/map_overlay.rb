class MapOverlay < ApplicationRecord
  acts_as_list
  has_and_belongs_to_many :localities
end
