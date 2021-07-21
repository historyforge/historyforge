class Architect < ApplicationRecord
  has_and_belongs_to_many :buildings
  validates :name, presence: true, length: { maximum: 255 }
  before_destroy :check_for_buildings

  def can_destroy?
    buildings.blank?
  end

  private

  def check_for_buildings
    throw(:abort) unless can_destroy?
  end
end
