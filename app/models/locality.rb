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
#  slug                 :string
#  short_name           :string
#  primary              :boolean          default(FALSE), not null
#
# Indexes
#
#  index_localities_on_slug  (slug) UNIQUE
#

# frozen_string_literal: true

# Locality means "City of Ithaca", "Village of Freeville" - a way to segment a single HistoryForge to keep records
# for multiple related places, but (in the future) be able to search them together or separately.
class Locality < ApplicationRecord
  acts_as_list
  validates :name, :short_name, presence: true, uniqueness: true
  before_validation :set_slug

  has_and_belongs_to_many :people, dependent: :nullify
  has_and_belongs_to_many :documents, dependent: :nullify
  has_many :buildings, dependent: :restrict_with_exception
  has_many :map_overlays, dependent: :restrict_with_exception
  has_many :census1850_records, dependent: :nullify, class_name: 'Census1850Record', inverse_of: :locality
  has_many :census1860_records, dependent: :nullify, class_name: 'Census1860Record', inverse_of: :locality
  has_many :census1870_records, dependent: :nullify, class_name: 'Census1870Record', inverse_of: :locality
  has_many :census1880_records, dependent: :nullify, class_name: 'Census1880Record', inverse_of: :locality
  has_many :census1900_records, dependent: :nullify, class_name: 'Census1900Record', inverse_of: :locality
  has_many :census1910_records, dependent: :nullify, class_name: 'Census1910Record', inverse_of: :locality
  has_many :census1920_records, dependent: :nullify, class_name: 'Census1920Record', inverse_of: :locality
  has_many :census1930_records, dependent: :nullify, class_name: 'Census1930Record', inverse_of: :locality
  has_many :census1940_records, dependent: :nullify, class_name: 'Census1940Record', inverse_of: :locality
  has_many :census1950_records, dependent: :nullify, class_name: 'Census1950Record', inverse_of: :locality

  default_scope -> { order(:position) }

  def located?
    latitude.present? && longitude.present?
  end

  def total_count
    CensusYears.sum { |year| send(:"census#{year}_records_count") }
  end

  def set_slug
    self.slug = name.parameterize
  end
end
