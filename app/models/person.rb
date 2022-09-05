# == Schema Information
#
# Table name: people
#
#  id                      :integer          not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  last_name               :string
#  first_name              :string
#  middle_name             :string
#  sex                     :string(12)
#  race                    :string(12)
#  name_prefix             :string
#  name_suffix             :string
#  searchable_name         :text
#  birth_year              :integer
#  is_birth_year_estimated :boolean          default("true")
#  pob                     :string
#  is_pob_estimated        :boolean          default("true")
#
# Indexes
#
#  people_name_trgm  (searchable_name)
#

# frozen_string_literal: true

# A person record is the glue that connects multiple census records to the same individual person. A person record
# itself is pretty sparse, mainly glue, but does not have to have census records.
class Person < ApplicationRecord
  include PersonNames
  include PgSearch::Model
  include Flaggable
  include DefineEnumeration
  include Versioning
  include FastMemoize

  attr_accessor :match_score

  define_enumeration :sex, %w{M F}
  define_enumeration :race, %w{W B M}

  CensusYears.each do |year|
    has_one :"census#{year}_record", dependent: :nullify, class_name: "Census#{year}Record"
  end

  has_and_belongs_to_many :photos, class_name: 'Photograph', dependent: :nullify

  validates :last_name, presence: true

  before_save :estimate_birth_year
  before_save :estimate_pob

  scope :uncensused, -> {
    qry = self
    CensusYears.each do |year|
      qry = qry.left_outer_joins(:"census#{year}_record")
    end
    qry.where CensusYears.map { |year| "#{CensusRecord.for_year(year).table_name}.id IS NULL" }.join(' AND ')
  }

  scope :with_census_records, -> {
    qry = self
    CensusYears.each do |year|
      qry = qry.includes(:"census#{year}_record")
    end
    qry
  }

  scope :photographed, -> {
    joins('INNER JOIN people_photographs ON people_photographs.person_id=people.id')
  }

  pg_search_scope :last_name_search,
                  against: %i[first_name last_name],
                  using: %i[dmetaphone]

  # To make the "Mark n Reviewed" button not show up because there is not a person review system at the moment
  def reviewed?
    true
  end

  # TODO: Move to service object
  def self.likely_matches_for(record)
    matches = where(sex: record.sex, last_name: record.last_name, first_name: record.first_name).order(:first_name, :middle_name)
    matches = last_name_search(record.last_name).where(sex: record.sex) unless matches.exists?
    unless matches.exists?
      matches = where(sex: record.sex, last_name: record.last_name).order(:first_name, :middle_name)
    end
    CensusYears.each do |year|
      matches = matches.includes(:"census#{year}_record")
    end
    matches.select { |match| match.census_records.blank? || match.similar_in_age?(record) }
  end

  def possible_unmatched_records
    CensusYears.map do |year|
      CensusRecord.for_year(year).where(person_id: nil, sex:, last_name:, first_name:)
    end.reduce(&:+)
  end
  memoize :possible_unmatched_records

  # Takes a census record and returns whether this person's age is within two years of the census record's age
  def similar_in_age?(target)
    (age_in_year(target.year) - (target.age || 0)).abs <= 2
  end

  def age_in_year(year)
    if birth_year
      year - birth_year
    else
      match = census_records.first
      if match
        diff = match.year - year
        (match.age || 0) - diff
      else
        -1
      end
    end
  end

  def census_records
    CensusYears.map { |year| send("census#{year}_record")}.compact
  end
  memoize :census_records

  def reset_census_records
    remove_instance_variable(:@census_records) if instance_variable_defined?(:@census_records)
  end

  def relation_to_head
    census_records.map(&:relation_to_head).uniq.join(', ')
  end

  def profession
    census_records.map(&:profession).uniq.join(', ')
  end

  def address
    census_records.map(&:street_address).compact_blank.uniq.join(', ')
  end

  def estimated_birth_year
    return birth_year if birth_year.present?

    records = census_records.select { |r| r.age.present? }
    return if records.blank?

    records.map { |r| r.year - r.age }.reduce(&:+) / records.size
  end

  private

  def estimate_birth_year
    self.birth_year = estimated_birth_year if birth_year.blank? && is_birth_year_estimated? && census_records.present?
  end

  def estimate_pob
    return if pob.present? || !is_pob_estimated? || census_records.blank?

    pobs = census_records.map(&:pob).compact.uniq
    self.pob = pobs.first if pobs.present?
  end

  def unattached?
    census_records.blank? && photos.blank?
  end
end
