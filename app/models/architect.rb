# == Schema Information
#
# Table name: architects
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

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
