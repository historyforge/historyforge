class PhysicalType < ApplicationRecord
  has_and_belongs_to_many :physical_formats

  def self.still_image
    where(name: 'Still Image').first
  end
end