# frozen_string_literal: true

# Locality means "City of Ithaca", "Village of Freeville" - a way to segment a single HistoryForge to keep records
# for multiple related places, but (in the future) be able to search them together or separately.
class Locality < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :buildings, dependent: :nullify

  CensusYears.each do |year|
    has_many :"census#{year}_records", inverse_of: :locality
  end

  def self.select_options
    order(:position).map { |item| [item.name, item.id] }
  end
end
