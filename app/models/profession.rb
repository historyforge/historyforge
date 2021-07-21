class Profession < ApplicationRecord
  belongs_to :profession_group
  belongs_to :profession_subgroup
end
