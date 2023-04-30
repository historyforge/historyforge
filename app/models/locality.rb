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
  validates :name, presence: true, uniqueness: true

  has_many :buildings, dependent: :nullify

  CensusYears.each do |year|
    has_many :"census#{year}_records", inverse_of: :locality
  end

  default_scope -> { order(:name) }

  before_destroy do
    throw(:abort) if census_record_count > 0
  end

  def self.select_options
    all.map { |item| [item.name, item.id] }
  end

  def census_record_count
    CensusYears.map { |year| self.public_send(:"census#{year}_records").count }.reduce(&:+)
  end
end
