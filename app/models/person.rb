# == Schema Information
#
# Table name: people
#
#  id                      :integer          not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  sex                     :string(12)
#  race                    :string
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
  include Flaggable
  include Versioning

  NAME_ATTRIBUTES = %w[first_name middle_name last_name name_prefix name_suffix].freeze

  attr_accessor :match_score

  define_enumeration :sex, %w[M F]
  define_enumeration :race, %w[W B Mu Mex In Ch Jp Fil Hin Kor]

  has_many :census1850_records, dependent: :nullify, class_name: 'Census1850Record', inverse_of: :person
  has_many :census1860_records, dependent: :nullify, class_name: 'Census1860Record', inverse_of: :person
  has_many :census1870_records, dependent: :nullify, class_name: 'Census1870Record', inverse_of: :person
  has_many :census1880_records, dependent: :nullify, class_name: 'Census1880Record', inverse_of: :person
  has_many :census1900_records, dependent: :nullify, class_name: 'Census1900Record', inverse_of: :person
  has_many :census1910_records, dependent: :nullify, class_name: 'Census1910Record', inverse_of: :person
  has_many :census1920_records, dependent: :nullify, class_name: 'Census1920Record', inverse_of: :person
  has_many :census1930_records, dependent: :nullify, class_name: 'Census1930Record', inverse_of: :person
  has_many :census1940_records, dependent: :nullify, class_name: 'Census1940Record', inverse_of: :person
  has_many :census1950_records, dependent: :nullify, class_name: 'Census1950Record', inverse_of: :person
  has_and_belongs_to_many :photos, class_name: 'Photograph', dependent: :nullify
  has_and_belongs_to_many :localities
  has_many :names, ->{ order('is_primary desc NULLS LAST, last_name asc, first_name asc, middle_name asc, name_suffix asc, name_prefix asc')},
           class_name: 'PersonName',
           dependent: :destroy,
           autosave: true,
           inverse_of: :person
  accepts_nested_attributes_for :names, allow_destroy: true, reject_if: proc { |p| p['last_name'].blank? }

  validate :validate_primary_name

  before_validation do
    self.sex = nil if sex.blank? || sex == 'on'
    self.race = nil if race.blank? || race == 'on'
  end

  scope :fuzzy_name_search, lambda { |names|
    names = Array.wrap(names)
    where(id: PersonName.select(:person_id)
                        .where(names.map { 'person_names.searchable_name % ?' }.join(' OR '), *names)
                        .where('person_names.person_id=people.id'))
  }

  scope :uncensused, lambda {
    qry = self
    CensusYears.each { |year| qry = qry.left_outer_joins(:"census#{year}_records") }
    qry.where CensusYears.map { |year| "#{CensusRecord.for_year(year).table_name}.id IS NULL" }.join(' AND ')
  }

  scope :with_census_records, lambda {
    qry = self
    CensusYears.each { |year| qry = qry.includes(:"census#{year}_records") }
    qry
  }

  scope :with_multiple_names, lambda {
    all
      .joins(:names)
      .group('people.id, person_names.last_name')
      .having('COUNT(person_names.last_name) > 1')
  }

  scope :photographed, lambda {
    joins('INNER JOIN people_photographs ON people_photographs.person_id=people.id')
  }

  scope :name_fuzzy_matches, lambda { |names|
    possible_names = names.squish.split.map { |name| People::Nicknames.matches_for(name) }
    query = joins(:names).group('people.id')
    possible_names.each do |name_set|
      conditions = name_set.map { 'person_names.searchable_name % ?' }.join(' OR ')
      query = query.where(conditions, *name_set)
    end
    query
  }

  scope :with_primary_name, lambda {
    joins(:names).where(names: { is_primary: true }).tap do
      select(select_values, 'concat_ws(\' \', person_names.name_prefix, person_names.first_name, person_names.middle_name, person_names.last_name, person_names.name_suffix) as found_name')
    end
  }

  def self.ransackable_attributes(_auth_object = nil)
    super + %w[name]
  end

  def self.ransackable_scopes(_auth_object = nil)
    super + %w[name_fuzzy_matches]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[names census_1850_records census_1860_records
       census_1870_records census_1880_records census_1900_records census_1910_records census_1920_records
       census_1930_records census_1940_records census_1950_records photos]
  end

  def name
    try(:found_name) || [name_prefix, first_name, middle_name, last_name, name_suffix].select(&:present?).join(' ')
  end

  def primary_name
    names.detect(&:is_primary?)
  end
  memoize :primary_name

  # To make the "Mark n Reviewed" button not show up because there is not a person review system at the moment
  def reviewed?
    true
  end

  def add_name_from(record)
    return if names.any? { |name| name.same_name_as?(record) }

    primary_name_record = names.build(is_primary: names.blank?).tap do |name|
      name.attributes = record.attributes.slice(*NAME_ATTRIBUTES)
    end
    pull_name_from(primary_name_record)
  end

  def add_name_from!(record)
    new_name = add_name_from(record)
    new_name&.save
  end

  def add_locality_from(record)
    return if localities.include?(record.locality)

    localities << record.locality
  end

  def possible_unmatched_records
    return unless primary_name

    CensusYears.sum do |year|
      CensusRecord.for_year(year).where(person_id: nil, sex:, last_name:, first_name:)
    end
  end
  memoize :possible_unmatched_records

  # Takes a census record and returns whether this person's age is within two years of the census record's age
  def similar_in_age?(target)
    (age_in_year(target.year) - (target.age || 0)).abs <= 2
  end

  def age_in_year(year)
    return year - birth_year if birth_year

    match = census_records.first
    if match
      diff = match.year - year
      (match.age || 0) - diff
    else
      -1
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

    aged_records.sum { |r| r.year - (r.age || 0) } / (census_records.length || 1)
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
    census_records.filter_map(&:pob).uniq.first
  end

  def unattached?
    census_records.blank? && photos.blank?
  end

  def validate_primary_name
    primary_names = names.to_a.select(&:is_primary)
    if primary_names.blank?
      errors.add(:base, 'Primary name missing.')
    elsif primary_names.size > 1
      errors.add(:base, 'Multiple primary names not allowed.')
    else
      pull_name_from(primary_names.first)
    end
  end

  def pull_name_from(name_record)
    assign_attributes(name_record.attributes.slice(*NAME_ATTRIBUTES))
  end
end
