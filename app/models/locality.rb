# == Schema Information
#
# Table name: localities
#
#  id                   :bigint           not null, primary key
#  name                 :string
#  latitude             :decimal(, )
#  longitude            :decimal(, )
#  position             :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  year_street_renumber :integer
#

# frozen_string_literal: true

# Locality means "City of Ithaca", "Village of Freeville" - a way to segment a single HistoryForge to keep records
# for multiple related places, but (in the future) be able to search them together or separately.
class Locality < ApplicationRecord
  validates :name, :short_name, presence: true, uniqueness: true
  before_validation :set_slug
  has_many :buildings, dependent: :restrict_with_exception
  has_many :map_overlays, dependent: :restrict_with_exception
  has_and_belongs_to_many :people

  CensusYears.each do |year|
    has_many :"census#{year}_records", inverse_of: :locality, dependent: :restrict_with_exception
  end

  default_scope -> { order(:name) }

  def self.select_options
    all.map { |item| [item.name, item.id] }
  end

  def located?
    latitude.present? && longitude.present?
  end

  def total_count
    CensusYears.map { |year| send(:"census#{year}_records_count") }.sum
  end

  def set_slug
    self.slug = name&.parameterize
  end
end
