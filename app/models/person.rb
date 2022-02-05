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

  define_enumeration :sex, %w{M F}
  define_enumeration :race, %w{W B M}

  CensusYears.each do |year|
    has_one :"census_#{year}_record", dependent: :nullify, class_name: "Census#{year}Record"
  end

  has_and_belongs_to_many :photos, class_name: 'Photograph', dependent: :nullify

  validates :last_name, :sex, :race, presence: true

  before_save :estimate_birth_year
  before_save :estimate_pob

  pg_search_scope :last_name_search,
                  against: :last_name,
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
      matches = matches.includes(:"census_#{year}_record")
    end
    matches.select { |match| match.census_records.blank? || match.similar_in_age?(record) }
  end

  # TODO: Move to service object
  def self.probable_match_for(record)
    matches = where(sex: record.sex, last_name: record.last_name, first_name: record.first_name).order(:first_name, :middle_name)
    probables = []
    if matches.present?
      matches.each do |match|
        probables << match if match.similar_in_age?(record)
      end
      if probables.any?
        return probables.first if probables.size == 1
        probables.each do |match|
          next if match.census_records.blank?
          match.census_records.each do |match_record|
            score = 0
            score += 1 if match_record.street_address == record.street_address
            score += 1 if match_record.relation_to_head == record.relation_to_head
            score += 1 if match_record.profession == record.profession
            match_record.fellows.each do |match_record_fellow|
              record.fellows.each do |fellow|
                if fellow.first_name == match_record_fellow.first_name && fellow.relation_to_head == match_record_fellow.relation_to_head
                  score += 1
                end
              end
            end
            return match if score >= 1
          end
        end
      end
    end
    nil
  end

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
    @census_records ||= CensusYears.map { |year| send("census_#{year}_record")}.compact
  end

  def relation_to_head
    census_records.map(&:relation_to_head).uniq.join(', ')
  end

  def profession
    census_records.map(&:profession).uniq.join(', ')
  end

  def address
    census_records.map(&:street_address).uniq.join(', ')
  end

  def estimated_birth_year
    return birth_year if birth_year.present?

    records = census_records&.select { |r| r.age.present? }
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
end
