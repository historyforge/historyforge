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
#  is_birth_year_estimated :boolean          default(TRUE)
#  pob                     :string
#  is_pob_estimated        :boolean          default(TRUE)
#  notes                   :text
#  description             :text
#
# Indexes
#
#  people_name_trgm  (searchable_name) USING gist
#

# frozen_string_literal: true

# A person record is the glue that connects multiple census records to the same individual person. A person record
# itself is pretty sparse, mainly glue, but does not have to have census records.
class Person < ApplicationRecord
  include PersonNames
  include PgSearch::Model
  include Flaggable
  include Versioning

  attr_accessor :match_score

  define_enumeration :sex, %w[M F]
  define_enumeration :race, %w[W B Mu Mex In Ch Jp Fil Hin Kor]

  CensusYears.each do |year|
    has_many :"census#{year}_records", dependent: :nullify, class_name: "Census#{year}Record"
  end

  has_and_belongs_to_many :photos, class_name: 'Photograph', dependent: :nullify

  validates :last_name, presence: true

  before_validation do
    self.sex = nil if sex.blank? || sex == 'on'
    self.race = nil if race.blank? || race == 'on'
  end

  scope :uncensused, -> {
    qry = self
    CensusYears.each { |year| qry = qry.left_outer_joins(:"census#{year}_records") }
    qry.where CensusYears.map { |year| "#{CensusRecord.for_year(year).table_name}.id IS NULL" }.join(' AND ')
  }

  scope :with_census_records, -> {
    qry = self
    CensusYears.each { |year| qry = qry.includes(:"census#{year}_records") }
    qry
  }

  scope :photographed, -> {
    joins('INNER JOIN people_photographs ON people_photographs.person_id=people.id')
  }

  # pg_search_scope :fuzzy_name_search,
  #                 against: %i[first_name last_name],
  #                 using: {
  #                   trigram: {
  #                     word_similarity: true
  #                   }
  #                 }

  # To make the "Mark n Reviewed" button not show up because there is not a person review system at the moment
  def reviewed?
    true
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
    CensusYears.map { |year| send("census#{year}_records") }.flatten.compact_blank
  end
  memoize :census_records

  def reset_census_records
    remove_instance_variable(:@census_records) if instance_variable_defined?(:@census_records)
  end

  def relatives
    fellows = census_records.flat_map(&:fellows).group_by(&:person_id)
    Person.where(id: fellows.keys).tap do |people|
      people.each { |person| person.instance_variable_set(:@census_records, fellows[person.id]) }
    end
  end
  memoize :relatives

  def relation_to_head
    census_records.select { |record| record.year >= 1880 }.map(&:relation_to_head).uniq.join(', ')
  end

  def occupation
    census_records.map(&:occupation).uniq.join(', ')
  end

  def address
    census_records.map(&:street_address).compact_blank.uniq.join(', ')
  end

  def estimated_birth_year
    return birth_year unless is_birth_year_estimated?

    aged_records = census_records.reject { |r| r.age&.> 120 }
    return if aged_records.blank?

    aged_records
      .map { |r| r.year - (r.age || 0) }
      .reduce(&:+) / (census_records.length || 1)
  end

  def save_with_estimates
    return if @saved_with_estimates
    self.is_birth_year_estimated = true
    self.is_pob_estimated = true
    estimate_birth_year
    estimate_pob
    @saved_with_estimates = true
    save
  end

  def estimate_birth_year
    return unless is_birth_year_estimated?

    self.birth_year = estimated_birth_year
  end

  def estimate_pob
    return pob unless is_pob_estimated?
    return unless is_pob_estimated?

    self.pob = estimated_pob
  end

  def estimated_pob
    census_records.map(&:pob).compact.uniq.first
  end

  def unattached?
    census_records.blank? && photos.blank?
  end
end
